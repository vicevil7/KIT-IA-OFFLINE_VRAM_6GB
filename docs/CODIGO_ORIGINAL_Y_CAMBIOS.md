# Procedencia de los scripts y cambios para portabilidad

La base de código procede de **11 archivos auténticos** recopilados del equipo de referencia. 

**Esta versión pública NO es byte a byte idéntica a los scripts probados en Windows**: se cambiaron las referencias rígidas a `F:\KIT_IA_OFFLINE` para usar `KIT_IA_OFFLINE_ROOT` y se independizó la ayuda de la función preexistente `ia`.

Cambios acotados:

- `ia_musica.ps1`, `ia_voz.ps1`, `ia_kokoro.ps1`, `ia_comfyui.ps1` y `ia_imagen.ps1`: la carpeta base se resuelve desde la variable de entorno `KIT_IA_OFFLINE_ROOT`, no reescribiendo la lógica de ejecución, control de proceso o comprobaciones.
- `kokoro_generar.py`: lee la misma variable de entorno y no se cambió la inferencia, fonemización ni la escritura del WAV.
- `ia_help_extensiones.ps1`:  Está disponible e integra la ayuda en `ia help` únicamente cuando el usuario ya dispone de la función principal `ia` compatible. 
- `ia_imagen_generar.py`, `ia_help_extensiones.json` y el workflow de ComfyUI: se conservaron **íntegros**, sin editar sus bytes. El workflow sigue vinculado al hash del generador.
- `ComfyUI-Z-Image-Turbo-model-paths.yaml`: se **genera localmente** a partir de la carpeta elegida, no se publica el YAML original sino uno de ejemplo.
- `tools/Preparar-Configuraciones.ps1` y `tools/Cargar-Comandos.ps1`: herramientas nuevas, preparación y carga validadas en PowerShell 7 en una carpeta aislada del equipo de referencia. la preparación **no sobrescribe archivos distintos**.

Los hashes de **los archivos públicos adaptados** figuran en `SHA256SUMS.txt`. Los hashes originales no deben usarse para validar los archivos adaptados.

## Pruebas y estado

- Python: sintaxis del helper y workflow validados localmente.
- Los 9 scripts PowerShell públicos pasaron el Parser de PowerShell 7 en Windows con 0 errores.
- Carga en sesión nueva `pwsh -NoProfile` con seis funciones presentes, 18 ejemplos en `ia_ayuda` e imagen predeterminada 1024×576.
- **No realizado:** ejecutar generación real con scripts públicos adaptados o instalar motores desde cero en un segundo equipo. Evidencia: `docs/VALIDACION_WINDOWS_2026-11-14.md`.
- No se ha realizado instalación limpia en un segundo equipo. **32 GB RAM: NO PROBADO NI AUDITADO; no se afirma compatibilidad con esa configuración.**
