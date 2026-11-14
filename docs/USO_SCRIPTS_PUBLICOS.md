# Uso de los scripts públicos adaptados

## Preparar directorios

Los motores (Ollama, Strata, ACE-Step, Handy, Piper, Kokoro y ComfyUI) y sus modelos **no están incluidos**. Deben instalarse primero usando las versiones/rutas de `docs/INSTALACION_WINDOWS.md`.

Ejemplo para un segundo PC; **elige un disco fiable**, no apuntes a tu instalación existente sin hacer copia previamente:

```powershell
$KitRoot = 'D:\KIT_IA_OFFLINE'
@('00_INSTALADORES','01_MODELOS','02_APLICACIONES','04_CONFIGURACIONES',
  '05_HASHES','06_PRUEBAS') | ForEach-Object {
    New-Item -ItemType Directory -Path (Join-Path $KitRoot $_) -Force | Out-Null
}
```

En PowerShell 7, desde la carpeta de este repositorio:

```powershell
# Solo vista previa, no escribe:
.\tools\Preparar-Configuraciones.ps1 -KitRoot $KitRoot
# Comprueba qué se copiará y, en un equipo NUEVO, aplica sin sobrescribir:
.\tools\Preparar-Configuraciones.ps1 -KitRoot $KitRoot -Aplicar
# Carga comandos solo para esta sesión (nunca altera $PROFILE):
. .\tools\Cargar-Comandos.ps1 -KitRoot $KitRoot
ia_ayuda
```

No ejecutes scripts no firmados sin revisarlos. Si PowerShell `RemoteSigned` bloquea un script por la marca de Internet y **has verificado su fuente e integridad**, consulta la documentación de Microsoft sobre `Unblock-File` para un archivo específico. **No modifiques la política global ni uses `Bypass` como procedimiento habitual**.

## Comandos

```powershell
ia_musica status
ia_musica on
ia_musica off
ia_voz 'Hola, esto es una prueba' -Voz davefx
ia_kokoro 'Hola' -Voz santa
ia_comfyui on
ia_comfyui status
ia_comfyui off
ia_imagen 'Un castillo medieval al amanecer'
ia_imagen 'Un bosque fantástico' -Ancho 720 -Alto 720 -Semilla 42
ia_ayuda
```

Si tu entorno contiene el gestor original de **Strata/Ollama** con el marcador de ayuda previsto, también podría funcionar `ia help` si no lo contiene, **`ia_help` es un comando autónomo creado**. El repositorio no reproduce la función base `ia` de ese entorno.

## Límites conocidos

- ComfyUI: 127.0.0.1:XXXXX, `--lowvram`, salida PNG a Descargas de Windows, valores predeterminados **1024×576**, semilla aleatoria.
- `ia_imagen`: ancho y alto de 256 a 1024, múltiplos de 16; no admite 1280×720 de momento.
- `ia_musica`: servidor 127.0.0.1:XXXXX, sin servidor Strata activo ni modelos Ollama cargados, comprobación de memoria y VRAM.
- La configuración de GGUF depende del nodo `UnetLoaderGGUF`, versiones de ComfyUI y pesos concretos descritos en la guía.
- `ia_imagen_generar.py` espera el workflow **exacto** con SHA `6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C`.
- La copia de scripts no descarga modelos ni paquetes. Comprobar `python`, `gguf`, dependencias y pesos antes de generar.
- Preparación y carga de scripts adaptados y verificados en Windows 11. **No** se ha realizado ejecución real de motores adaptados ni instalación desde cero en otro equipo. **32 GB de RAM NO se han probado ni auditado.** Este repositorio no es un instalador automático validado en otros equipos.
