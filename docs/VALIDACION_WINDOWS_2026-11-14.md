# Validación de preparación y carga en Windows 11 — 14/11/2026

**Estado:** superada la prueba de integración **sin motores**, en el equipo de referencia con PowerShell 7. No confundir con una instalación completa desde cero ni con un ensayo en otro equipo.

## Integridad y sintaxis

- PowerShell Parser sobre **9 scripts `.ps1`**: 9 `OK`, 0 errores.
- Ningún motor de IA arrancado, ningún archivo del kit original modificado en esa prueba de sintaxis.

## Prueba aislada de preparación

- Extracción en una carpeta de validación nueva en nuevo directorio; no sobre la instalación original.
- `tools/Preparar-Configuraciones.ps1` en **vista previa**: 11 elementos previstos, 0 archivos creados en destino.
- Con `-Aplicar`: **10 ficheros copiados + YAML generado = 11 configuraciones**.
- Las 10 copias se contrastaron por SHA-256 con el paquete público.
- El YAML generado apunta a la raíz de pruebas.

## Sesión limpia

- Se ejecutó una nueva instancia de `pwsh` sin perfil de usuario.
- El cargador `tools/Cargar-Comandos.ps1` permitió encontrar las seis funciones `ia_musica`, `ia_voz`, `ia_kokoro`, `ia_comfyui`, `ia_imagen` e `ia_ayuda`.
- `ia_ayuda`: 18 ejemplos verificados.
- Resolución predeterminada anunciada: **1024 × 576**.
- No se arrancaron servidores, no se instalaron paquetes o modelos, no se tocó el perfil del usuario ni se modificó la instalación original.
- Resultado final reportado por el test: **CORRECTO**.

## Cobertura y límites de este test

| Requisito | Resultado |
|---|---|
| Análisis de sintaxis de scripts PowerShell | 9/9 correcto |
| Preparación de 11 configuraciones en ruta alternativa | Correcta |
| Carga de seis funciones en sesión sin perfil | Correcta |
| Ayuda con 18 ejemplos | Correcta |
| YAML con ruta de modelos adaptable | Correcto |
| Ejecutar música/voz/imagen con código público adaptado | **No realizado** |
| Instalar motores y modelos desde cero | **No realizado** |
| Prueba en otro PC | **No realizada** |
| 32 GB RAM / 6 GB VRAM | **NO PROBADO NI AUDITADO; no se afirma compatibilidad** |
| Seguridad integral, auditoría de dependencias y licencias | **No realizada** |
