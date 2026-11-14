# Validación de preparación y carga en Windows 11 — 14/11/2026

**Estado:** superada la prueba de integración **sin motores**, en el equipo de referencia. Resultados proporcionados por la persona que ejecutó el script de prueba en PowerShell 7. No confundir con una instalación completa desde cero ni con un ensayo en otro equipo.

## Integridad y sintaxis

- ZIP de referencia `KIT_IA_OFFLINE_GITHUB_REVISADO.zip`: hash SHA-256 coincidente con la referencia del test anterior.
- PowerShell Parser sobre **9 scripts `.ps1`**: 9 `OK`, 0 errores.
- Ningún motor de IA arrancado, ningún archivo del kit original modificado en esa prueba de sintaxis.

## Prueba aislada de preparación

- Extracción en una carpeta de validación nueva de la unidad **E:**; no sobre la instalación original.
- `tools/Preparar-Configuraciones.ps1` en **vista previa**: 11 elementos previstos, 0 archivos creados en destino.
- Con `-Aplicar`: **10 ficheros copiados + YAML generado = 11 configuraciones**.
- Las 10 copias se contrastaron por SHA-256 con el paquete público.
- El YAML generado apunta a la raíz de pruebas en E: (no a F:).

## Sesión limpia

- Se ejecutó una nueva instancia de `pwsh` sin perfil de usuario.
- El cargador `tools/Cargar-Comandos.ps1` permitió encontrar las seis funciones `ia_musica`, `ia_voz`, `ia_kokoro`, `ia_comfyui`, `ia_imagen` e `ia_ayuda`.
- `ia_ayuda`: 18 ejemplos verificados.
- Resolución predeterminada anunciada: **1024 × 576**.
- No se arrancaron servidores, no se instalaron paquetes o modelos, no se tocó el perfil del usuario y no se modificó la instalación original de F:.
- Resultado final reportado por el test: **CORRECTO**.

## Cobertura y límites de este test

| Requisito | Resultado |
|---|---|
| Integridad del ZIP original del test | Verificada en Windows por SHA-256 |
| Análisis de sintaxis de scripts PowerShell | 9/9 correcto |
| Preparación de 11 configuraciones en ruta alternativa | Correcta |
| Carga de seis funciones en sesión sin perfil | Correcta |
| Ayuda con 18 ejemplos | Correcta |
| YAML con ruta de modelos adaptable | Correcto |
| Ejecutar música/voz/imagen con código público adaptado | **Pendiente** |
| Instalar motores y modelos desde cero | **Pendiente** |
| Prueba en otro PC (incluido 32 GB RAM / 6 GB VRAM) | **Pendiente** |
| Seguridad integral, auditoría de dependencias y licencias | **Pendiente** |

La duplicación de la línea «COMANDOS CARGADOS» en la captura de la prueba no impidió cargar las funciones; no se investigó su causa específica. Este documento conserva solo evidencia técnica necesaria, sin nombres de cuentas, rutas de perfil ni identificadores del equipo.
