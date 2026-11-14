function global:ia_comfyui {
    [CmdletBinding()]
    param(
        [ValidateSet("on","off","status")]
        [string]$Accion = "status"
    )

    $ErrorActionPreference = "Stop"

$base = [string]$env:KIT_IA_OFFLINE_ROOT
if ([string]::IsNullOrWhiteSpace($base)) {
    throw 'Define KIT_IA_OFFLINE_ROOT cargando tools/Cargar-Comandos.ps1 -KitRoot <ruta>.'
}
$base = [System.IO.Path]::GetFullPath($base)
    $portable = "$base\02_APLICACIONES\ComfyUI\ComfyUI_windows_portable"
    $python = "$portable\python_embeded\python.exe"
    $yaml = "$base\04_CONFIGURACIONES\ComfyUI-Z-Image-Turbo-model-paths.yaml"
    $estado = "$base\04_CONFIGURACIONES\ia_comfyui_estado.json"
    $logs = "$base\06_PRUEBAS"

    function Test-IaComfyProcess {
        param($Info)

        if ($null -eq $Info -or !$Info.pid -or !$Info.startTicks) {
            return $false
        }

        $p = Get-Process -Id ([int]$Info.pid) -ErrorAction SilentlyContinue

        if ($null -eq $p) {
            return $false
        }

        try {
            $rutaCorrecta = [string]::Equals(
                [string]$p.Path,
                $python,
                [StringComparison]::OrdinalIgnoreCase
            )

            $inicioCorrecto = (
                [string]$p.StartTime.ToUniversalTime().Ticks -eq
                [string]$Info.startTicks
            )

            return ($rutaCorrecta -and $inicioCorrecto)
        }
        catch {
            return $false
        }
    }

    $info = $null

    if (Test-Path -LiteralPath $estado -PathType Leaf) {
        try {
            $info = Get-Content -LiteralPath $estado -Raw |
                ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            throw "Estado guardado invalido. Revisar antes de actuar."
        }
    }

    switch ($Accion) {
        "status" {
            if (!(Test-IaComfyProcess $info)) {
                Write-Host "COMFYUI: SIN INSTANCIA GESTIONADA ACTIVA"

                if ($null -ne $info) {
                    Write-Warning "Hay un registro anterior; revisar antes de iniciar."
                }
                return
            }

            Write-Host "COMFYUI: PROCESO ACTIVO" -ForegroundColor Green
            Write-Host "PID: $($info.pid)"

            try {
                $escucha = @(
                    Get-NetTCPConnection -LocalAddress "127.0.0.1" `
                        -LocalPort 8188 -State Listen `
                        -ErrorAction SilentlyContinue |
                    Where-Object { $_.OwningProcess -eq [int]$info.pid }
                )

                if ($escucha.Count -eq 0) {
                    throw "La instancia no posee el puerto esperado."
                }

                $api = Invoke-RestMethod `
                    -Uri "http://127.0.0.1:8188/system_stats" `
                    -TimeoutSec 5

                if (!$api.system) {
                    throw "Respuesta API incompleta."
                }

                Write-Host "API: CORRECTA" -ForegroundColor Green
                Write-Host "URL: http://127.0.0.1:8188"
            }
            catch {
                Write-Warning "Proceso activo, pero API aun no confirmada: $_"
            }
        }

        "on" {
            if ($null -ne $info) {
                if (Test-IaComfyProcess $info) {
                    Write-Host "COMFYUI YA ESTA INICIADO: PID $($info.pid)"
                    return
                }

                throw "Existe un estado anterior sin proceso valido. No se sobrescribe."
            }

            foreach ($ruta in @(
                $python,
                "$portable\ComfyUI\main.py",
                $yaml
            )) {
                if (!(Test-Path -LiteralPath $ruta -PathType Leaf)) {
                    throw "Falta componente: $ruta"
                }
            }

            $ocupado = @(
                Get-NetTCPConnection -LocalPort 8188 -State Listen `
                    -ErrorAction SilentlyContinue
            )

            if ($ocupado.Count -gt 0) {
                throw "Puerto 8188 ocupado. No se altera otro proceso."
            }

            $marca = Get-Date -Format "yyyyMMdd-HHmmss-fffffff"
            $stdout = Join-Path $logs "ia_comfyui-$marca.stdout.log"
            $stderr = Join-Path $logs "ia_comfyui-$marca.stderr.log"

            $variables = @(
                "HF_HUB_OFFLINE",
                "TRANSFORMERS_OFFLINE",
                "HF_HUB_DISABLE_TELEMETRY"
            )

            $anteriores = @{}
            $p = $null

            try {
                foreach ($nombre in $variables) {
                    $anteriores[$nombre] = [Environment]::GetEnvironmentVariable(
                        $nombre, "Process"
                    )
                    [Environment]::SetEnvironmentVariable(
                        $nombre, "1", "Process"
                    )
                }

                $argumentos = '-s "ComfyUI\main.py" ' +
                    '--listen 127.0.0.1 --port 8188 ' +
                    '--lowvram --offline --disable-auto-launch ' +
                    '--disable-assets --windows-standalone-build ' +
                    '--extra-model-paths-config "' + $yaml + '"'

                $p = Start-Process `
                    -FilePath $python `
                    -ArgumentList $argumentos `
                    -WorkingDirectory $portable `
                    -WindowStyle Hidden `
                    -RedirectStandardOutput $stdout `
                    -RedirectStandardError $stderr `
                    -PassThru

                $p.Refresh()

                $datos = @{
                    pid = $p.Id
                    startTicks = [string]$p.StartTime.ToUniversalTime().Ticks
                    stdout = $stdout
                    stderr = $stderr
                    started = (Get-Date).ToString("o")
                }

                $datos | ConvertTo-Json |
                    Set-Content -LiteralPath $estado -Encoding UTF8

                Write-Host "COMFYUI: PROCESO INICIADO" -ForegroundColor Green
                Write-Host "PID: $($p.Id)"
                Write-Host "URL: http://127.0.0.1:8188"
                Write-Host "Comprobar disponibilidad con: ia_comfyui status"
            }
            catch {
                if ($null -ne $p) {
                    try {
                        $p.Refresh()
                        if (!$p.HasExited) {
                            Stop-Process -Id $p.Id -ErrorAction Stop
                        }
                    }
                    catch {
                        Write-Warning "Comprobar manualmente el PID creado."
                    }
                }

                throw
            }
            finally {
                foreach ($nombre in $variables) {
                    [Environment]::SetEnvironmentVariable(
                        $nombre, $anteriores[$nombre], "Process"
                    )
                }
            }
        }

        "off" {
            if ($null -eq $info) {
                Write-Host "COMFYUI: YA ESTABA APAGADO"
                return
            }

            if (!(Test-IaComfyProcess $info)) {
                throw "El PID guardado no corresponde al proceso original. No se detiene."
            }

            $appPid = [int]$info.pid

            Stop-Process -Id $appPid -ErrorAction Stop

            try {
                Wait-Process -Id $appPid -Timeout 15 -ErrorAction Stop
            }
            catch {
                if (Get-Process -Id $appPid -ErrorAction SilentlyContinue) {
                    throw "No se confirmo la detencion. Se conserva el estado."
                }
            }

            $marca = Get-Date -Format "yyyyMMdd-HHmmss-fffffff"
            $archivado = "$estado.off-$marca.json"

            Move-Item -LiteralPath $estado -Destination $archivado `
                -ErrorAction Stop

            Write-Host "COMFYUI: DETENIDO" -ForegroundColor Green
            Write-Host "PID DETENIDO: $appPid"
            Write-Host "REGISTRO ARCHIVADO: $archivado"
        }
    }
}
