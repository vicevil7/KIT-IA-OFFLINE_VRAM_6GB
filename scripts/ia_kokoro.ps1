function ia_kokoro {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Texto,

        [ValidateSet("santa","dora","alex")]
        [string]$Voz = "santa",

        [ValidateRange(0.7,1.3)]
        [double]$Velocidad = 1.0
    )

    try {
        $base = [string]$env:KIT_IA_OFFLINE_ROOT
        if ([string]::IsNullOrWhiteSpace($base)) {
            throw 'Define KIT_IA_OFFLINE_ROOT cargando tools/Cargar-Comandos.ps1 -KitRoot <ruta>.'
        }
        $base = [System.IO.Path]::GetFullPath($base)
        $python = "$base\02_APLICACIONES\Kokoro-TTS\Scripts\python.exe"
        $motor = "$base\04_CONFIGURACIONES\kokoro_generar.py"
        $destino = "$base\06_PRUEBAS"

        $nombres = @{
            santa = "em_santa"
            dora  = "ef_dora"
            alex  = "em_alex"
        }

        $nombreVoz = $nombres[$Voz.ToLowerInvariant()]

        foreach ($ruta in @($python, $motor, $destino)) {
            if (!(Test-Path -LiteralPath $ruta)) {
                throw "Falta componente: $ruta"
            }
        }

        $velocidadTexto = $Velocidad.ToString(
            [System.Globalization.CultureInfo]::InvariantCulture
        )

        $salida = (
            & $python -I $motor `
                "--texto=$Texto" `
                "--voz=$nombreVoz" `
                "--velocidad=$velocidadTexto" `
                "--destino=$destino" 2>&1 |
            Out-String
        ).Trim()

        if ($LASTEXITCODE -ne 0) {
            throw "Fallo de Kokoro: $salida"
        }

        if ($salida -notmatch "RESULTADO: CORRECTO") {
            throw "Kokoro no confirmo el resultado."
        }

        Write-Output $salida
    }
    catch {
        Write-Output "ERROR IA_KOKORO: $($_.Exception.Message)"
    }
}
