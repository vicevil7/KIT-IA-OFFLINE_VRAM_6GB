function ia_musica {
    [CmdletBinding()]
    param(
        [ValidateSet("on", "off", "status")]
        [string]$Accion = "status"
    )

$base = [string]$env:KIT_IA_OFFLINE_ROOT
if ([string]::IsNullOrWhiteSpace($base)) {
    throw 'Define KIT_IA_OFFLINE_ROOT cargando tools/Cargar-Comandos.ps1 -KitRoot <ruta>.'
}
$base = [System.IO.Path]::GetFullPath($base)
    $app = Join-Path $base "02_APLICACIONES\ACE-Step-1.5"
    $exe = "$app\python_embeded\python.exe"
    $pipeline = "$app\acestep\acestep_v15_pipeline.py"
    $logs = Join-Path $base "06_PRUEBAS"

    try {
        $procesos = @(
            Get-CimInstance Win32_Process -Filter "Name='python.exe'" |
            Where-Object {
                $_.ExecutablePath -ieq $exe -and
                $_.CommandLine -match 'acestep_v15_pipeline\.py'
            }
        )

        $puertos = @(
            Get-NetTCPConnection -LocalPort 7860 -State Listen `
                -ErrorAction SilentlyContinue
        )

        switch ($Accion) {
            "status" {
                Write-Output "===== ACE-STEP ====="
                Write-Output "INSTANCIAS: $($procesos.Count)"

                foreach ($p in $procesos) {
                    $detalle = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
                    Write-Output "PID: $($p.ProcessId)"

                    if ($detalle) {
                        Write-Output "RAM: $([math]::Round($detalle.WorkingSet64 / 1MB)) MiB"
                    }
                }

                if ($puertos.Count -eq 0) {
                    Write-Output "SERVIDOR: SIN ESCUCHAR"
                } else {
                    foreach ($p in $puertos) {
                        Write-Output "ESCUCHANDO: $($p.LocalAddress):7860 | PID $($p.OwningProcess)"
                    }
                }

                if ($procesos.Count -eq 1 -and
                    @($puertos | Where-Object {
                        $_.OwningProcess -eq $procesos[0].ProcessId -and
                        $_.LocalAddress -eq "127.0.0.1"
                    }).Count -gt 0) {
                    Write-Output "WEB: http://127.0.0.1:7860"
                    Write-Output "ESTADO: SERVIDOR LOCAL ACTIVO"
                }
                elseif ($procesos.Count -eq 0) {
                    Write-Output "ESTADO: ACE-STEP DETENIDO"
                }
                else {
                    Write-Output "ESTADO: ARRANCANDO O REQUIERE REVISION"
                }
            }

            "off" {
                if ($procesos.Count -eq 0) {
                    Write-Output "ACE-Step ya esta detenido."
                    return
                }

                if ($procesos.Count -ne 1) {
                    throw "Varias instancias detectadas. No se detiene ninguna."
                }

                $pidACE = [int]$procesos[0].ProcessId

                $confirmacion = Get-CimInstance Win32_Process `
                    -Filter "ProcessId=$pidACE" -ErrorAction Stop

                if (!$confirmacion -or
                    $confirmacion.ExecutablePath -ine $exe -or
                    $confirmacion.CommandLine -notmatch 'acestep_v15_pipeline\.py') {
                    throw "La identidad del proceso ha cambiado. No se detiene."
                }

                Stop-Process -Id $pidACE -Force -ErrorAction Stop

                Write-Output "ACE-Step: orden de detencion enviada al PID $pidACE."
                Write-Output "Strata y Ollama: sin modificaciones."
            }

            "on" {
                if ($procesos.Count -gt 0) {
                    Write-Warning "ACE-Step ya tiene un proceso activo."
                    return
                }

                if ($puertos.Count -gt 0) {
                    throw "El puerto 7860 esta ocupado. No se inicia."
                }

                foreach ($ruta in @(
                    $exe,
                    $pipeline,
                    "$app\checkpoints\acestep-v15-turbo"
                )) {
                    if (!(Test-Path -LiteralPath $ruta)) {
                        throw "Falta componente: $ruta"
                    }
                }

                $strata = @(
                    Get-NetTCPConnection -LocalPort 19081 -State Listen `
                        -ErrorAction SilentlyContinue
                )

                if ($strata.Count -gt 0) {
                    Write-Warning "El servidor de Strata esta activo en el puerto 19081. Revisa su consumo antes de iniciar ACE-Step."
                    return
                }

                if (!(Get-Command ollama -ErrorAction SilentlyContinue)) {
                    throw "No se puede comprobar Ollama."
                }

                $ollama = @(& ollama ps 2>&1)

                if ($LASTEXITCODE -ne 0) {
                    throw "No se pudo consultar el estado de Ollama."
                }

                $cargados = @(
                    $ollama |
                    Select-Object -Skip 1 |
                    Where-Object { "$_".Trim() }
                )

                if ($cargados.Count -gt 0) {
                    Write-Warning "Hay $($cargados.Count) modelo(s) Ollama cargado(s). No se inicia ACE-Step."
                    return
                }

                $salidaGPU = @(
                    & nvidia-smi --query-gpu=memory.free `
                        --format=csv,noheader,nounits 2>$null
                )

                if ($LASTEXITCODE -ne 0 -or $salidaGPU.Count -ne 1) {
                    throw "No se pudo comprobar la VRAM."
                }

                $vram = 0

                if (![int]::TryParse($salidaGPU[0].Trim(), [ref]$vram)) {
                    throw "No se pudo interpretar la VRAM disponible."
                }

                $ram = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB

                Write-Output "VRAM LIBRE: $vram MiB"
                Write-Output "RAM LIBRE: $([math]::Round($ram,2)) GiB"

                if ($vram -lt 4600 -or $ram -lt 20) {
                    Write-Warning "Recursos por debajo del umbral de precaucion. No se inicia."
                    return
                }

                $fecha = Get-Date -Format "yyyyMMdd-HHmmss"
                $stdout = "$logs\ACE-Step-$fecha.stdout.log"
                $stderr = "$logs\ACE-Step-$fecha.stderr.log"

                $argumentos = @(
                    $pipeline,
                    "--port", "7860",
                    "--server-name", "127.0.0.1",
                    "--language", "en",
                    "--config_path", "acestep-v15-turbo",
                    "--init_llm", "false",
                    "--offload_to_cpu", "true",
                    "--batch_size", "1",
                    "--init_service", "true",
                    "--download-source", "huggingface"
                )

                $variables = @{
                    HF_HUB_OFFLINE = "1"
                    TRANSFORMERS_OFFLINE = "1"
                    HF_DATASETS_OFFLINE = "1"
                    HF_HUB_DISABLE_TELEMETRY = "1"
                    HF_HUB_DISABLE_IMPLICIT_TOKEN = "1"
                    GRADIO_ANALYTICS_ENABLED = "False"
                    DO_NOT_TRACK = "1"
                    CHECK_UPDATE = "false"
                }

                $nuevo = Start-Process `
                    -FilePath $exe `
                    -ArgumentList $argumentos `
                    -WorkingDirectory $app `
                    -Environment $variables `
                    -WindowStyle Hidden `
                    -RedirectStandardOutput $stdout `
                    -RedirectStandardError $stderr `
                    -PassThru `
                    -ErrorAction Stop

                Write-Output "ACE-Step: arranque solicitado."
                Write-Output "PID: $($nuevo.Id)"
                Write-Output "VENTANA: OCULTA"
                Write-Output "LLM AUXILIAR: DESACTIVADO"
                Write-Output "MODO HF OFFLINE: ACTIVADO"
                Write-Output "WEB: http://127.0.0.1:7860"
                Write-Output "LOGS: $stdout"
                Write-Output "El servidor puede tardar en quedar disponible."
            }
        }
    }
    catch {
        Write-Output "ERROR IA_MUSICA: $($_.Exception.Message)"
    }
}
