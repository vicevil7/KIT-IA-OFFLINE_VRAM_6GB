<#
.SYNOPSIS
  Prepara solamente los 11 archivos de configuración en una raíz KIT_IA_OFFLINE existente.
.DESCRIPTION
  Modo predeterminado: vista previa, ninguna escritura. -Aplicar copia los 10 archivos
  públicos y genera YAML en 04_CONFIGURACIONES, SIN sobreescribir archivos diferentes.
  No instala Python, ComfyUI, modelos ni modifica $PROFILE o el cortafuegos.
.EXAMPLE
  .\tools\Preparar-Configuraciones.ps1 -KitRoot 'D:\KIT_IA_OFFLINE'
.EXAMPLE
  .\tools\Preparar-Configuraciones.ps1 -KitRoot 'D:\KIT_IA_OFFLINE' -Aplicar
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$KitRoot,
    [switch]$Aplicar
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$kit = [System.IO.Path]::GetFullPath($KitRoot).TrimEnd([char[]]@('\','/'))
$destino = Join-Path $kit '04_CONFIGURACIONES'
if (!(Test-Path -LiteralPath $kit -PathType Container)) {
    throw "La raíz elegida no existe: $kit"
}
if (!(Test-Path -LiteralPath $destino -PathType Container)) {
    throw "Crea la carpeta 04_CONFIGURACIONES antes de continuar: $destino"
}
$archivos = @(
    'ia_musica.ps1','ia_voz.ps1','ia_kokoro.ps1','kokoro_generar.py',
    'ia_comfyui.ps1','ia_imagen.ps1','ia_imagen_generar.py',
    'ia_help_extensiones.ps1','ia_help_extensiones.json',
    'ComfyUI-Z-Image-Turbo-workflow.json'
)
$pendientes = [System.Collections.Generic.List[object]]::new()
foreach ($nombre in $archivos) {
    $origen = if ($nombre -eq 'ComfyUI-Z-Image-Turbo-workflow.json') {
        Join-Path $repo ('config\' + $nombre)
    } else {
        Join-Path $repo ('scripts\' + $nombre)
    }
    $dest = Join-Path $destino $nombre
    if (!(Test-Path -LiteralPath $origen -PathType Leaf)) {
        throw "Archivo fuente no disponible: $origen"
    }
    if (Test-Path -LiteralPath $dest) {
        if ((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -ine
            (Get-FileHash -LiteralPath $origen -Algorithm SHA256).Hash) {
            throw "Existe un archivo diferente. No se sobreescribe: $dest"
        }
        Write-Host "YA COINCIDE: $nombre"
    } else {
        $pendientes.Add([pscustomobject]@{Fuente=$origen;Destino=$dest;Nombre=$nombre})
        Write-Host "PREPARADO: $nombre"
    }
}
$yaml = Join-Path $destino 'ComfyUI-Z-Image-Turbo-model-paths.yaml'
# ComfyUI recibe '/' en Windows; duplicar comilla simple para escapado YAML.
$raizModelo = (($kit -replace '\\','/') + '/01_MODELOS/IMAGENES/Z-Image-Turbo').Replace("'", "''")
$contenidoYaml = @(
    '# KIT IA OFFLINE - fichero generado localmente',
    'kit_zimage:',
    "  base_path: '$raizModelo'",
    '  diffusion_models: diffusion_models',
    '  text_encoders: text_encoders',
    '  vae: vae'
) -join "`n"
if (Test-Path -LiteralPath $yaml) {
    $ya = [System.IO.File]::ReadAllText($yaml).Trim()
    if ($ya -cne $contenidoYaml.Trim()) {
        throw "YAML ya existe y difiere; no se sobreescribe: $yaml"
    }
    Write-Host 'YA COINCIDE: YAML'
} else {
    Write-Host 'PREPARADO: YAML de rutas'
}
if (!$Aplicar) {
    Write-Host 'MODO: VISTA PREVIA; NO SE HA ESCRITO NINGUN ARCHIVO'
    return
}
# Se verifican todos los destinos antes de copiar. No se sustituye ninguna configuración.
foreach ($archivo in $pendientes) {
    Copy-Item -LiteralPath $archivo.Fuente -Destination $archivo.Destino -ErrorAction Stop
    if ((Get-FileHash -LiteralPath $archivo.Fuente -Algorithm SHA256).Hash -ine
        (Get-FileHash -LiteralPath $archivo.Destino -Algorithm SHA256).Hash) {
        throw "SHA256 distinto tras copiar: $($archivo.Nombre)"
    }
    Write-Host "COPIADO: $($archivo.Nombre)"
}
if (!(Test-Path -LiteralPath $yaml)) {
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($yaml,$contenidoYaml+"`n",$utf8)
    Write-Host 'GENERADO: YAML de rutas'
}
Write-Host 'RESULTADO: CONFIGURACIONES PREPARADAS. MODELOS Y PROGRAMAS NO INSTALADOS.'
