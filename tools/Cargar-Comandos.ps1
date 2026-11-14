<#
.SYNOPSIS
  Carga en ESTA sesión los comandos públicos del KIT_IA_OFFLINE.
.DESCRIPTION
  No edita el perfil PowerShell. Requiere que los archivos hayan sido preparados
  previamente en <KitRoot>\04_CONFIGURACIONES. No ejecuta motores al cargarlos.
.EXAMPLE
  . .\tools\Cargar-Comandos.ps1 -KitRoot 'D:\KIT_IA_OFFLINE'
#>
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$KitRoot)
$ErrorActionPreference = 'Stop'
$raiz = [System.IO.Path]::GetFullPath($KitRoot)
$config = Join-Path $raiz '04_CONFIGURACIONES'
if (!(Test-Path -LiteralPath $config -PathType Container)) {
    throw "No existe carpeta de configuración: $config"
}
$lista = @(
    'ia_musica.ps1',
    'ia_voz.ps1',
    'ia_kokoro.ps1',
    'ia_comfyui.ps1',
    'ia_imagen.ps1',
    'ia_help_extensiones.ps1'
)
foreach ($nombre in $lista) {
    if (!(Test-Path -LiteralPath (Join-Path $config $nombre) -PathType Leaf)) {
        throw "Falta configurar: $nombre"
    }
}
$env:KIT_IA_OFFLINE_ROOT = $raiz
foreach ($nombre in $lista) {
    . (Join-Path $config $nombre)
}
Write-Host "COMANDOS CARGADOS: $raiz"
Write-Host 'AYUDA: ia_ayuda (ia help si ya existe un gestor ia compatible)'
