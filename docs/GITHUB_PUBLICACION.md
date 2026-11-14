# Qué publicar en GitHub y cómo preparar el repositorio

**Objetivo:** compartir el procedimiento que funcionó en el laboratorio, con configuración reutilizable y sin publicar modelos pesados, programas de terceros ni datos privados.

## 1. Qué incluye la versión revisada

- Documentación (`README.md`, `docs/`) y manifiestos SHA-256.
- Los **11 archivos originales** recuperados, con modificaciones acotadas de portabilidad para PowerShell y Kokoro; workflow original íntegro y JSON íntegro.
- Herramientas nuevas `tools/Preparar-Configuraciones.ps1`, `tools/Cargar-Comandos.ps1` y `tests/validar_fuentes.py`.
- Plantilla de YAML y herramienta para generarlo según la raíz local elegida.

**Estado de pruebas:** análisis de sintaxis PowerShell 7 (9/9) y preparación/carga simulada en Windows 11 (11/11 configuraciones, 6/6 funciones, 18 ejemplos) correctos. **No se ha probado la ejecución de los motores adaptados ni una instalación limpia en otro ordenador**. No etiquetar como instalador completo. Véase `docs/VALIDACION_WINDOWS_2026-11-14.md`.

## 2. Qué falta para una distribución ejecutable completa

- **Superado:** ensayo de `Preparar-Configuraciones.ps1` y `Cargar-Comandos.ps1` en PowerShell 7, carpeta aislada de E: y carga sin perfil. **Pendiente:** ejecutar los motores con las funciones adaptadas y probar una instalación limpia en otro equipo.
- Instalar las dependencias y modelos desde las fuentes originales, verificar hashes oficiales y probar todos los motores por separado.
- **Completado:** licencia MIT autorizada por el titular para el código propio y documentación original; revisar por separado las atribuciones de terceros.
- Probar compatibilidad con 32 GB RAM / 6 GB VRAM antes de declararla mínima.
- Automatizar la descarga/instalación solo si se decide hacerlo y se puede comprobar y auditar.

## 3. No incluir en GitHub

| Clase de fichero | Razón |
|---|---|
| Pesos `.gguf`, `.safetensors`, `.onnx`, `.bin`, `.pt`, checkpoints, modelos de voz | Tamaño, licencias, procedencia y distribución de terceros |
| Carpetas `00_INSTALADORES`, `01_MODELOS`, `02_APLICACIONES` | Binarios y dependencias de terceros, gran tamaño |
| `C:\Users\...\Microsoft.PowerShell_profile.ps1` | Preferencias personales y posibles secretos |
| Archivos `ia_comfyui_estado.json` o `*.off-*.json` | PID, historial del equipo, rutas de logs |
| Logs, informes `06_PRUEBAS`, wav/png generados o CSV de mediciones sin sanitizar | Nombres, rutas, prompts o información de equipo |
| `.env`, tokens, claves API, claves GitHub/HF, credenciales | Información sensible |
| Backups Second Brain y script real de Obsidian, XML de tarea programada | No forman parte del kit y revelan estructura privada |
| Documento `INSTRUCCIONES_INSTALACION_IA_OFFLINE.md` **privado** | Contiene rutas particulares e incidencias personales |

`.gitignore` **no es una medida de seguridad suficiente**: un archivo ya versionado o añadido explícitamente puede terminar publicado. Revisar siempre contenido y diffs.

## 4. Ruta local y sanitización

Los scripts públicos de esta versión **ya usan** la variable de entorno `KIT_IA_OFFLINE_ROOT`, establecida por `tools/Cargar-Comandos.ps1`. El YAML de ComfyUI se genera desde la ruta local elegida usando `tools/Preparar-Configuraciones.ps1`.

No deben publicarse los archivos **originales privados** ni copiar una instalación local completa a GitHub. Analizar todos los diffs antes de confirmar un commit y buscar rutas privadas, contraseñas, tokens y otros metadatos. **No asumir que una búsqueda por expresiones regulares detecta todos los secretos.**

## 5. Licencias y autoría

- **Scripts y documentación original propios:** licencia **MIT** autorizada por el titular; archivo `LICENSE` incluido, copyright **2026 vicevil.dev**. Se debe mantener el aviso de copyright y licencia al redistribuir este material. **No** concede derechos sobre componentes de terceros ni permite relicenciarlos.
- **ComfyUI** y su extensión **ComfyUI-GGUF** tienen sus licencias propias. El repositorio del nodo GGUF ofrece texto Apache-2.0: https://github.com/city96/ComfyUI-GGUF/blob/main/LICENSE.
- **Z-Image Turbo GGUF:** modelo publicado como `apache-2.0` en su ficha, https://huggingface.co/unsloth/Z-Image-Turbo-GGUF. Verificar licencia de cada pieza auxiliar individual.
- **ACE-Step 1.5:** ficha del modelo con licencia MIT: https://huggingface.co/ACE-Step/Ace-Step1.5. Comprobar licencia de aplicación y dependencias separadamente.
- **Kokoro ONNX:** librería MIT, modelo Kokoro declarado Apache-2.0 por su proyecto: https://github.com/thewh1teagle/kokoro-onnx.
- **Piper:** los model cards pueden contener condiciones de **datasets distintos**; Sharvard cita CC-BY 3.0 y DaveFX CC0. Respetar los avisos, además de la licencia del proyecto de voces: https://huggingface.co/rhasspy/piper-voices.
- **Handy y Ollama:** verificar condiciones de la versión exacta de cada proyecto y sus modelos; un instalador no debe presentarse como código propio.

No copiar logos, pesos, aplicaciones, scripts de terceros ni código del proyecto original al repositorio por mera comodidad. Publicar instrucciones/enlaces y atribuciones.

## 6. Flujo Git sugerido — después de revisar

Crear un **repositorio vacío** en GitHub con nombre sugerido `KIT-IA-OFFLINE` (o el que elijas), sin subir allí el manual privado. En la carpeta del ZIP descomprimido, después de inspeccionar su contenido:

```powershell
git init
git status --short
git add README.md LICENSE .gitignore docs config tools scripts tests SHA256SUMS.txt
git diff --cached --name-only
git diff --cached --check
# Revisión humana: comprobar TODOS los ficheros staged antes de confirmar
git diff --cached
```

Cuando hayas revisado la diferencia y estén limpios:

```powershell
git commit -m "docs: document local offline AI kit"
# Crear el repositorio remoto en tu cuenta, copiar la URL desde GitHub
# git remote add origin <URL-REAL-DEL-REPOSITORIO>
# git branch -M main
# git push -u origin main
```

No se proporciona una URL de repositorio inventada. Tampoco hay acción de subida realizada automáticamente por este paquete.

## 7. Qué mejoras comunicar al público

- Fecha y sistema de pruebas, incluyendo **64 GB RAM / 6 GB VRAM**.
- Especificar que **32 GB RAM / 6 GB VRAM está pendiente de ensayo**, con instrucciones de medición, y que algunos modelos deben ejecutarse individualmente.
- Usar etiquetas transparentes: **Probado**, **Pendiente**, **[Inferencia]** y **No incluido**.
- Documentar resoluciones y límites: **1024×576** predeterminado; 720×720 mediante parámetros; no prometer 1280×720 en el comando actual.
- Mantener versiones revisadas y comprobantes de hash; no sustituir en los ejemplos por versiones «latest» sin repetir pruebas.
- Para un futuro release, publicar scripts propios examinados, un archivo de hashes reproducible y registros de pruebas **sanitizados** de al menos otro equipo.

## 8. Verificación previa al primer `git push`

- [ ] No hay rutas de cuentas ni equipo personal.
- [ ] No hay credenciales ni tokens en historial Git ni archivos staged.
- [ ] No hay binarios/modelos de terceros.
- [ ] Los scripts públicos están adaptados a partir de los originales y los cambios están documentados.
- [ ] Workflow JSON tiene el SHA final correcto y está libre de datos personales.
- [ ] Los hashes publicitados corresponden a los archivos exactos de la versión fijada.
- [x] Se eligió licencia MIT para el código propio; `LICENSE` está incluido. Las atribuciones de terceros siguen separadas y deben revisarse al redistribuir componentes de terceros.
- [ ] La guía deja claros los requisitos **verificados** y las compatibilidades **no verificadas**.
- [x] Se ha probado la preparación de archivos en un directorio nuevo y la carga de funciones sin perfil, en el equipo original.
- [ ] Se ha probado una instalación limpia y generación real con las versiones adaptadas en otro equipo.
- [ ] El README deja claro que el ZIP no es un instalador automático.
