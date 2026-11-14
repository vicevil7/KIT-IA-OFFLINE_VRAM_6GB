<#
.SYNOPSIS
  Inventario de archivos reales del KIT_IA_OFFLINE y copia opcional para revision PRIVADA.
.DESCRIPTION
  Por defecto: solo lectura, comprueba nombre, SHA256 y posibles indicios de datos sensibles.
  Con -Copiar: copia UNICAMENTE 11 archivos de configuracion a una nueva carpeta de
  una carpeta de revisión privada fuera del repositorio, sin sobreescribir y sin publicarlos.
  No lee ni copia modelos, voces, caches, perfiles Windows, logs o respaldos.
  Por defecto no escribe. Con -Copiar escribe únicamente en DestinoBase.
  No realiza llamadas a Internet ni git push.
  Usar solamente cuando el origen este conectado y estable. La base USB SSK original
  tenia eventos de E/S; evitar su lectura si vuelve a presentar desconexiones.
.EXAMPLE
  .\Recolectar-Configuraciones.ps1
.EXAMPLE
  .\Recolectar-Configuraciones.ps1 -KitRoot 'D:\KIT_IA_OFFLINE' -DestinoBase 'D:\REVISION_KIT' -Copiar
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$KitRoot = [string]$env:KIT_IA_OFFLINE_ROOT,

    [Parameter()]
    [string]$DestinoBase = (Join-Path $HOME 'KIT_IA_OFFLINE_REVISION_PRIVADA'),

    [Parameter()]
    [switch]$Copiar
)

$ErrorActionPreference = 'Stop'

$archivos = @(
    'ia_musica.ps1',
    'ia_voz.ps1',
    'ia_kokoro.ps1',
    'kokoro_generar.py',
    'ia_comfyui.ps1',
    'ia_imagen.ps1',
    'ia_imagen_generar.py',
    'ia_help_extensiones.ps1',
    'ia_help_extensiones.json',
    'ComfyUI-Z-Image-Turbo-model-paths.yaml',
    'ComfyUI-Z-Image-Turbo-workflow.json'
)

$hashesConocidos = @{
    'ia_imagen.ps1' = 'FD2A1AC997EEA345287F64C430A2E84C5C7E218ADE4B6E0554283D5C0A5036B5'
    'ia_imagen_generar.py' = '7F4FB5CF979718D2BC6EFCC37DB141908A605FC14FAD8D9191902286E103DD2C'
    'ia_help_extensiones.json' = 'EBE6F096CBE8F107BF2FC1EAB3018E2635438039E1808BB5EBCDF897772BB628'
    'ComfyUI-Z-Image-Turbo-workflow.json' = '6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C'
}

$patronesPrivacidad = [ordered]@{
    RutaPerfilWindows = '(?i)[A-Z]:\\Users\\[^\\\r\n"'' ]+'
    RutaAbsoluta = '(?i)\b[A-Z]:\\'
    ClaveAPI = '(?i)(?:sk-[A-Za-z0-9_-]{15,}|ghp_[A-Za-z0-9]{20,}|hf_[A-Za-z0-9]{20,})'
    Autorizacion = '(?i)Authorization\s*[:=]|Bearer\s+[A-Za-z0-9._-]{10,}'
    ClaveEnTexto = '(?i)(?:password|secret|api_key|access_token)\s*[:=]'
    Correo = '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
}

try {
    Write-Host '===== INVENTARIO PRIVADO PARA GITHUB ====='
    Write-Host ('MODO: ' + $(if ($Copiar) { 'COPIA PRIVADA' } else { 'SOLO LECTURA / SIN COPIAS' }))
    Write-Host "ORIGEN: $KitRoot"

    if (-not (Test-Path -LiteralPath $KitRoot -PathType Container)) {
        throw "No existe la raiz del kit: $KitRoot"
    }

    $config = Join-Path $KitRoot '04_CONFIGURACIONES'
    if (-not (Test-Path -LiteralPath $config -PathType Container)) {
        throw "No existe la carpeta configuraciones: $config"
    }

    $destino = $null
    if ($Copiar) {
        $marca = Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'
        $destino = "$DestinoBase-$marca"
        if (Test-Path -LiteralPath $destino) {
            throw "El destino ya existe, no se sobrescribe: $destino"
        }
        $unidadOrigen = (Get-Item -LiteralPath $KitRoot).FullName.Substring(0, 2)
        $unidadDestino = [IO.Path]::GetPathRoot($destino).TrimEnd('\')
        if ($unidadOrigen -ieq $unidadDestino) {
            throw 'El destino debe residir en una unidad diferente de la unidad origen.'
        }
    }

    $resultado = [System.Collections.Generic.List[string]]::new()
    $copiados = 0
    $faltantes = 0
    $alertas = 0
    $datosParaCopiar = [System.Collections.Generic.List[object]]::new()

    foreach ($nombre in $archivos) {
        $origen = Join-Path $config $nombre
        if (-not (Test-Path -LiteralPath $origen -PathType Leaf)) {
            Write-Host "NO ENCONTRADO: $nombre" -ForegroundColor Yellow
            $resultado.Add("FALTA: $nombre")
            $faltantes++
            continue
        }

        $objeto = Get-Item -LiteralPath $origen -ErrorAction Stop
        if ($objeto.Length -gt 5MB) {
            throw "Archivo de configuracion inesperadamente grande: $nombre"
        }

        if ($objeto.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Enlace/reparse point inesperado: $nombre"
        }

        $sha = (Get-FileHash -LiteralPath $origen -Algorithm SHA256).Hash
        $integridad = 'SIN REFERENCIA PUBLICADA'
        if ($hashesConocidos.ContainsKey($nombre)) {
            $integridad = if ($sha -ieq $hashesConocidos[$nombre]) {
                'COINCIDE HASH FINAL CONOCIDO'
            } else {
                'ADVERTENCIA: HASH DISTINTO DEL FINAL DOCUMENTADO'
            }
        }

        Write-Host "ARCHIVO: $nombre"
        Write-Host "BYTES: $($objeto.Length)"
        Write-Host "SHA256: $sha"
        Write-Host "INTEGRIDAD: $integridad"

        $texto = [IO.File]::ReadAllText($origen)
        $banderas = @(
            foreach ($entrada in $patronesPrivacidad.GetEnumerator()) {
                if ([regex]::IsMatch($texto, [string]$entrada.Value)) {
                    [string]$entrada.Key
                }
            }
        )

        if ($banderas.Count -gt 0) {
            $alertas++
            Write-Host ('REVISAR PRIVACIDAD: ' + ($banderas -join ', ')) -ForegroundColor Yellow
        } else {
            Write-Host 'HEURISTICAS PRIVACIDAD: SIN ALERTAS (NO GARANTIZA AUSENCIA DE SECRETOS)'
        }

        Write-Host ''
        $resultado.Add("$sha  $nombre  [$integridad]  [PRIVACIDAD:$($banderas -join ',')]")
        $datosParaCopiar.Add([pscustomobject]@{ Origen = $origen; Nombre = $nombre; Sha = $sha })
    }

    if ($Copiar) {
        if ($datosParaCopiar.Count -eq 0) {
            throw 'No se encontro ningun archivo que copiar.'
        }

        # Solo se crea la carpeta tras comprobar todos los archivos.
        $null = New-Item -ItemType Directory -Path $destino -ErrorAction Stop
        foreach ($item in $datosParaCopiar) {
            $salida = Join-Path $destino $item.Nombre
            Copy-Item -LiteralPath $item.Origen -Destination $salida -ErrorAction Stop
            $verificado = (Get-FileHash -LiteralPath $salida -Algorithm SHA256).Hash
            if ($verificado -ine $item.Sha) {
                throw "Copia con SHA distinto: $($item.Nombre)"
            }
            $copiados++
        }
        $reporte = Join-Path $destino 'INVENTARIO_PRIVADO.txt'
        @(
            'NO PUBLICAR SIN REVISION MANUAL',
            'Estos ficheros pueden incluir rutas privadas o configuraciones locales.',
            ('Generado: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),
            $resultado
        ) | Set-Content -LiteralPath $reporte -Encoding utf8
    }

    Write-Host '===== RESUMEN ====='
    Write-Host "ARCHIVOS LOCALIZADOS: $($datosParaCopiar.Count)"
    Write-Host "NO ENCONTRADOS: $faltantes"
    Write-Host "ALERTAS HEURISTICAS: $alertas"
    Write-Host "COPIADOS EN E: $copiados"
    if ($destino) { Write-Host "CARPETA PRIVADA: $destino" }
    Write-Host 'GITHUB: NO SE HA PUBLICADO NADA'
    Write-Host 'MODELOS: NO COPIADOS'
    Write-Host 'ORIGINALES: SIN MODIFICAR'
    Write-Host 'RESULTADO FINAL: CORRECTO'
}
catch {
    Write-Host 'RESULTADO FINAL: ERROR' -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host 'NO SE HACE LIMPIEZA AUTOMATICA NI SE PUBLICAN DATOS.'
}
