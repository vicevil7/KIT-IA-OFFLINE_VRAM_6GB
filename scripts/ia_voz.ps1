function ia_voz {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Texto,

        [ValidateSet("davefx","sharvard")]
        [string]$Voz = "davefx"
    )

    try {
        $base = [string]$env:KIT_IA_OFFLINE_ROOT
        if ([string]::IsNullOrWhiteSpace($base)) {
            throw 'Define KIT_IA_OFFLINE_ROOT cargando tools/Cargar-Comandos.ps1 -KitRoot <ruta>.'
        }
        $base = [System.IO.Path]::GetFullPath($base)
        $python = "$base\02_APLICACIONES\Piper-TTS\Scripts\python.exe"
        $nombre = "es_ES-$Voz-medium"
        $modelo = "$base\01_MODELOS\VOZ\Piper\$nombre\$nombre.onnx"
        $config = "$modelo.json"
        $destino = "$base\06_PRUEBAS"

        foreach ($ruta in @($python,$modelo,$config,$destino)) {
            if (!(Test-Path -LiteralPath $ruta)) {
                throw "Falta componente: $ruta"
            }
        }

        $fecha = Get-Date -Format "yyyyMMdd-HHmmss-fff"
        $wav = Join-Path $destino "Piper-$nombre-$fecha.wav"

        if (Test-Path -LiteralPath $wav) {
            throw "El archivo WAV ya existe."
        }

        $inicio = Get-Date

        $salida = (
            & $python -m piper -m $modelo -f $wav -- $Texto 2>&1 |
            Out-String
        )

        if ($LASTEXITCODE -ne 0) {
            throw "Piper devolvio un error: $salida"
        }

        if (!(Test-Path -LiteralPath $wav -PathType Leaf)) {
            throw "Piper no ha creado el WAV."
        }

        $datos = [System.IO.File]::ReadAllBytes($wav)

        if ($datos.Length -le 44) {
            throw "Archivo WAV vacio o demasiado pequeno."
        }

        $riff = [System.Text.Encoding]::ASCII.GetString($datos,0,4)
        $wave = [System.Text.Encoding]::ASCII.GetString($datos,8,4)

        if ($riff -ne "RIFF" -or $wave -ne "WAVE") {
            throw "Cabecera WAV incorrecta."
        }

        $segundos = [math]::Round(
            ((Get-Date) - $inicio).TotalSeconds, 2
        )

        Write-Output "===== PIPER TTS ====="
        Write-Output "VOZ: $Voz"
        Write-Output "TIEMPO GENERACION: $segundos segundos"
        Write-Output "TAMANO: $($datos.Length) bytes"
        Write-Output "ARCHIVO: $wav"
        Write-Output "RESULTADO: CORRECTO"
    }
    catch {
        Write-Output "ERROR IA_VOZ: $($_.Exception.Message)"
    }
}
