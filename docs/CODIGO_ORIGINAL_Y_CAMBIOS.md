# Procedencia de los scripts y cambios para portabilidad

La base de código procede de **11 archivos auténticos** recopilados del equipo de referencia el 14/11/2026. El archivo ZIP privado original tenía SHA-256
`16FBCAA1251D415A5A3A45133BD792B35DF63FE2FFA6F2B6599389107828D680`.

**Esta versión pública NO es byte a byte idéntica a los scripts probados en Windows**: se cambiaron las referencias rígidas a `F:\KIT_IA_OFFLINE` para usar `KIT_IA_OFFLINE_ROOT` y se independizó la ayuda de la función preexistente `ia`.

Cambios acotados:

- `ia_musica.ps1`, `ia_voz.ps1`, `ia_kokoro.ps1`, `ia_comfyui.ps1` y `ia_imagen.ps1`: la carpeta base se resuelve desde la variable de entorno `KIT_IA_OFFLINE_ROOT`. No se reescribió la lógica de ejecución, control de proceso o comprobaciones.
- `kokoro_generar.py`: lee la misma variable de entorno; no se cambió la inferencia, fonemización ni la escritura del WAV.
- `ia_help_extensiones.ps1`: `ia_ayuda` siempre está disponible; integra la ayuda en `ia help` únicamente cuando el usuario ya dispone de la función principal `ia` compatible. No sobrescribe un gestor `ia` distinto.
- `ia_imagen_generar.py`, `ia_help_extensiones.json` y el workflow de ComfyUI: se conservaron **íntegros**, sin editar sus bytes. El workflow sigue vinculado al hash incrustado en el generador.
- `ComfyUI-Z-Image-Turbo-model-paths.yaml`: se **genera localmente** a partir de la carpeta elegida; no se publica el YAML original que apuntaba a F:.
- `tools/Preparar-Configuraciones.ps1` y `tools/Cargar-Comandos.ps1`: herramientas nuevas; preparación y carga validadas en PowerShell 7 en una carpeta aislada del equipo de referencia (14/11/2026). Se incluyen para revisión/ensayo; la preparación **no sobrescribe archivos distintos**.

## Hashes de origen (ZIP privado)

| Archivo | SHA-256 original |
|---|---|
| `ia_musica.ps1` | `9393490948F6E96FD8BE407753186DD207414E9C88F0814089B963212850B661` |
| `ia_voz.ps1` | `5D43F0D02B700B61A12BEB6923DEF0D8F605056A47A9C3FB4A56F86000FC21E1` |
| `ia_kokoro.ps1` | `14598C56A0E9279F23FCBDD1B67C87F4E61C00B60E98E06CD15558B1129048A0` |
| `kokoro_generar.py` | `AF15D07E69E9772C01960BDC8789CFC815E6A573884B34A74C0B746B96020CE5` |
| `ia_comfyui.ps1` | `65D34C6E03954A75C8DF332F25C16FD4763ADDECC0195B42AEF7DA4F47D55868` |
| `ia_imagen.ps1` | `FD2A1AC997EEA345287F64C430A2E84C5C7E218ADE4B6E0554283D5C0A5036B5` |
| `ia_imagen_generar.py` | `7F4FB5CF979718D2BC6EFCC37DB141908A605FC14FAD8D9191902286E103DD2C` |
| `ia_help_extensiones.ps1` | `F697984F603DC70CD0D92F423CA1E6B5D28CF2CCBCDB4C5EDFCE1E06734243E8` |
| `ia_help_extensiones.json` | `EBE6F096CBE8F107BF2FC1EAB3018E2635438039E1808BB5EBCDF897772BB628` |
| `ComfyUI-Z-Image-Turbo-workflow.json` | `6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C` |

Los hashes de **los archivos públicos adaptados** figuran en `SHA256SUMS.txt`. Los hashes originales no deben usarse para validar los archivos adaptados.

## Pruebas y estado

- ZIP privado: SHA-256 comprobado, 11/11 archivos con hash coincidente.
- Python: sintaxis del helper y workflow validados localmente.
- Los 9 scripts PowerShell públicos pasaron el Parser de PowerShell 7 en Windows (0 errores).
- Preparación simulada en E: desde ZIP: vista previa sin escrituras, 11 archivos preparados, hashes coincidentes, YAML de ruta generada.
- Carga en sesión nueva `pwsh -NoProfile`: seis funciones presentes, 18 ejemplos en `ia_ayuda`, imagen predeterminada 1024×576.
- **Pendiente:** ejecutar generación real con scripts adaptados e instalar motores en un segundo equipo. Evidencia: `docs/VALIDACION_WINDOWS_2026-11-14.md`.
- No se ha realizado instalación limpia en un segundo equipo. **No se afirma compatibilidad verificada con 32 GB RAM.**
