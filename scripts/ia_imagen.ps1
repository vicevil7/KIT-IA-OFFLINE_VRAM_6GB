function global:ia_imagen {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Descripcion,

        [ValidateRange(256,1024)]
        [int]$Ancho = 1024,

        [ValidateRange(256,1024)]
        [int]$Alto = 576,

        [long]$Semilla = -1,

        [string]$Salida = "",

        [string]$Carpeta = ""
    )

    $ErrorActionPreference = "Stop"

$base = [string]$env:KIT_IA_OFFLINE_ROOT
if ([string]::IsNullOrWhiteSpace($base)) {
    throw 'Define KIT_IA_OFFLINE_ROOT cargando tools/Cargar-Comandos.ps1 -KitRoot <ruta>.'
}
$base = [System.IO.Path]::GetFullPath($base)

    $portable = "$base\02_APLICACIONES\ComfyUI\ComfyUI_windows_portable"

    $python = "$portable\python_embeded\python.exe"

    $generador = "$base\04_CONFIGURACIONES\ia_imagen_generar.py"

    $workflow = "$base\04_CONFIGURACIONES\ComfyUI-Z-Image-Turbo-workflow.json"

    $estado = "$base\04_CONFIGURACIONES\ia_comfyui_estado.json"

    $pruebas = "$base\06_PRUEBAS"

    $iniciadoAqui = $false

    function Test-IaImagenInstancia {
        param($Info)

        if (
            $null -eq $Info -or
            !$Info.pid -or
            !$Info.startTicks
        ) {
            return $false
        }

        $p = Get-Process `
            -Id ([int]$Info.pid) `
            -ErrorAction SilentlyContinue

        if ($null -eq $p) {
            return $false
        }

        try {
            return (
                [string]::Equals(
                    [string]$p.Path,
                    $python,
                    [StringComparison]::OrdinalIgnoreCase
                ) -and
                [string]$p.StartTime.ToUniversalTime().Ticks -eq
                [string]$Info.startTicks
            )
        }
        catch {
            return $false
        }
    }

    try {
        if (
            [string]::IsNullOrWhiteSpace(
                $Descripcion
            )
        ) {
            throw "Debes escribir una descripcion."
        }

        if (
            $Ancho % 16 -ne 0 -or
            $Alto % 16 -ne 0
        ) {
            throw "Ancho y alto deben ser multiplos de 16."
        }

        if ($Salida -and $Carpeta) {
            throw "Utiliza -Salida o -Carpeta, no ambas."
        }

        foreach ($ruta in @(
            $python,
            $generador,
            $workflow
        )) {
            if (!(Test-Path -LiteralPath $ruta -PathType Leaf)) {
                throw "Falta componente: $ruta"
            }
        }

        if (!(Get-Command ia_comfyui -CommandType Function -ErrorAction SilentlyContinue)) {
            . "$base\04_CONFIGURACIONES\ia_comfyui.ps1"
        }

        $info = $null

        if (Test-Path -LiteralPath $estado -PathType Leaf) {
            $info = Get-Content -LiteralPath $estado -Raw |
                ConvertFrom-Json -ErrorAction Stop
        }

        $escuchas = @(
            Get-NetTCPConnection `
                -LocalPort 8188 `
                -State Listen `
                -ErrorAction SilentlyContinue
        )

        if ($null -ne $info) {
            if (!(Test-IaImagenInstancia $info)) {
                throw "Existe un estado previo no valido."
            }
        }
        elseif ($escuchas.Count -gt 0) {
            throw "Puerto 8188 ocupado por una instancia no gestionada."
        }
        else {
            Write-Host "INICIANDO COMFYUI..." -ForegroundColor Cyan

            ia_comfyui on

            $iniciadoAqui = $true

            if (!(Test-Path -LiteralPath $estado -PathType Leaf)) {
                throw "No se registro el servidor iniciado."
            }

            $info = Get-Content -LiteralPath $estado -Raw |
                ConvertFrom-Json -ErrorAction Stop
        }

        $limite = (Get-Date).AddSeconds(120)
        $disponible = $false

        while ((Get-Date) -lt $limite) {
            if (!(Test-IaImagenInstancia $info)) {
                throw "El proceso gestionado no esta activo."
            }

            try {
                $escucha = @(
                    Get-NetTCPConnection `
                        -LocalAddress "127.0.0.1" `
                        -LocalPort 8188 `
                        -State Listen `
                        -ErrorAction SilentlyContinue |
                    Where-Object {
                        $_.OwningProcess -eq [int]$info.pid
                    }
                )

                if ($escucha.Count -gt 0) {
                    $api = Invoke-RestMethod `
                        -Uri "http://127.0.0.1:8188/system_stats" `
                        -TimeoutSec 5

                    if ($null -ne $api.system) {
                        $disponible = $true
                        break
                    }
                }
            }
            catch {
                # El servidor puede estar arrancando.
            }

            Start-Sleep -Seconds 2
        }

        if (!$disponible) {
            throw "ComfyUI no respondio correctamente."
        }

        $argumentos = @(
            "--workflow", $workflow,
            "--portable", $portable,
            "--pruebas", $pruebas,
            "--prompt", $Descripcion,
            "--ancho", [string]$Ancho,
            "--alto", [string]$Alto,
            "--semilla", [string]$Semilla
        )

        if (
            ![string]::IsNullOrWhiteSpace(
                $Salida
            )
        ) {
            $argumentos += @(
                "--salida",
                $Salida
            )
        }

        if (
            ![string]::IsNullOrWhiteSpace(
                $Carpeta
            )
        ) {
            $argumentos += @(
                "--carpeta",
                $Carpeta
            )
        }

        Write-Host "GENERANDO IMAGEN..." -ForegroundColor Cyan

        & $python -X utf8 -u -s $generador @argumentos

        if ($LASTEXITCODE -ne 0) {
            throw "El generador devolvio un error."
        }
    }
    finally {
        if ($iniciadoAqui) {
            try {
                Write-Host "DETENIENDO COMFYUI..." -ForegroundColor Cyan

                ia_comfyui off
            }
            catch {
                Write-Warning (
                    "No se confirmo el apagado: " +
                    $_.Exception.Message
                )
            }
        }
    }
}
