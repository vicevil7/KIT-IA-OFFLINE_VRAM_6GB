function global:Show-IaHelpAddons {
    $base = [string]$env:KIT_IA_OFFLINE_ROOT
    if ([string]::IsNullOrWhiteSpace($base)) {
        Write-Warning 'Define KIT_IA_OFFLINE_ROOT antes de consultar la ayuda.'
        return
    }
    $ruta = Join-Path ([IO.Path]::GetFullPath($base)) '04_CONFIGURACIONES\ia_help_extensiones.json' 

    if (!(Test-Path -LiteralPath $ruta -PathType Leaf)) {
        Write-Host "Registro de extensiones no disponible."
        return
    }

    try {
        $entradas = @(
            Get-Content -LiteralPath $ruta -Raw -Encoding UTF8 |
                ConvertFrom-Json -ErrorAction Stop
        )

        Write-Host ""
        Write-Host "=== MUSICA, VOZ Y EXTENSIONES ===" -ForegroundColor Cyan

        $mostradas = 0

        foreach ($entrada in $entradas) {
            $nombre = [string]$entrada.funcion
            $ejemplo = [string]$entrada.ejemplo
            $descripcion = [string]$entrada.descripcion

            if ([string]::IsNullOrWhiteSpace($nombre) -or
                [string]::IsNullOrWhiteSpace($ejemplo)) {
                continue
            }

            $disponible = Get-Command $nombre `
                -CommandType Function `
                -ErrorAction SilentlyContinue

            if ($disponible) {
                Write-Host ("{0,-42} {1}" -f $ejemplo, $descripcion)
                $mostradas++
            }
        }

        Write-Host ""
        Write-Host "Extensiones disponibles: $mostradas ejemplos"
        Write-Host "Registro ampliable: ia_help_extensiones.json"
    }
    catch {
        Write-Host "Error cargando ayuda adicional: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# En otros equipos la función principal 'ia' de Strata/Ollama puede no existir.
# 'ia_ayuda' ofrece los comandos de este kit sin sobreescribir el gestor ajeno.
function global:ia_ayuda { Show-IaHelpAddons }

$comando = Get-Command ia -CommandType Function -ErrorAction SilentlyContinue
if ($null -eq $comando) {
    return
}
$original = [string]$comando.Definition

$marcador = 'Write-Host "Nota: no cambiar durante peticiones activas."'

if (!$original.Contains("Show-IaHelpAddons")) {
    $numero = [regex]::Matches(
        $original,
        [regex]::Escape($marcador)
    ).Count

    if ($numero -ne 1) {
        Write-Warning "La función ia existente no tiene el marcador esperado; usa ia_ayuda sin modificar ia."
        return
    }

    $nuevo = $original.Replace(
        $marcador,
        $marcador + "`r`n            Show-IaHelpAddons"
    )

    $tokens = $null
    $errores = $null

    $null = [System.Management.Automation.Language.Parser]::ParseInput(
        $nuevo, [ref]$tokens, [ref]$errores
    )

    if (@($errores).Count -ne 0) {
        throw "Error de sintaxis extendiendo ia."
    }

    Set-Item -Path Function:\global:ia `
        -Value ([scriptblock]::Create($nuevo)) `
        -Force
}
