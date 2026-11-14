# Publicación en GitHub y alcance del repositorio

## Repositorio

Nombre: **`vicevil7/KIT-IA-OFFLINE_VRAM_6GB`**. La visibilidad puede mantenerse **privada** mientras se revisa el contenido y modificarse a pública cuando el titular lo decida.

Este repositorio contiene documentación, scripts propios adaptados y un workflow JSON de ComfyUI. **No incluye motores, binarios, modelos, voces ni pesos**. No es un instalador completo verificado en otros equipos.

## Evidencia disponible

- 11 archivos originales recogidos del equipo de referencia, comprobados por SHA-256.
- Nueve scripts PowerShell públicos: sintaxis revisada con PowerShell 7, sin errores.
- Preparación local simulada en Windows 11: 11 configuraciones, incluido YAML con ruta adaptable, sin sobrescritura de archivos existentes en la prueba.
- Carga de seis funciones en sesión sin perfil y ayuda con 18 ejemplos.
- Generaciones originales de referencia realizadas con **Windows 11 + 64 GB RAM + RTX 3060 Laptop de 6 GB VRAM**.

**32 GB de RAM: NO PROBADO NI AUDITADO.** No se afirma compatibilidad, mínimos certificados ni rendimiento para esa configuración. Tampoco se ha verificado una instalación completa en un segundo ordenador o una generación real usando los scripts públicos adaptados.

[Detalles de validación](VALIDACION_WINDOWS_2026-11-14.md) · [Límites de hardware](COMPATIBILIDAD_32GB_6GB.md).

## Qué no debe subirse

- Pesos, checkpoints y modelos (`.gguf`, `.safetensors`, `.onnx`, `.bin`, etc.), programas, instaladores o copias de entornos Python.
- Archivos privados originales, respaldos, rutas de cuentas personales, exportaciones de perfiles de PowerShell o registros de los equipos.
- Tokens, claves, contraseñas, `.env`, archivos de estado de procesos, sesiones, logs sin revisar ni documentos privados.

**Importante:** `.gitignore` no impide publicar accidentalmente un secreto ya confirmado en Git. Revisar archivos y commits, también el historial, antes de cambiar la visibilidad.

## Derechos y licencias

Los scripts y la documentación propios están licenciados mediante **MIT** (`LICENSE`, copyright 2026 vicevil.dev). El software y los modelos de terceros mantienen sus propias licencias. La licencia MIT de este repositorio **no se extiende** a binarios y modelos ajenos.

Fuentes relevantes: [Ollama](https://ollama.com/), [ComfyUI](https://github.com/Comfy-Org/ComfyUI), [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF), [ACE-Step](https://github.com/ace-step/ACE-Step-1.5), [Handy](https://github.com/cjpais/Handy), [Piper voices](https://huggingface.co/rhasspy/piper-voices), [Kokoro ONNX](https://github.com/thewh1teagle/kokoro-onnx), [Z-Image Turbo GGUF](https://huggingface.co/unsloth/Z-Image-Turbo-GGUF). Para redistribuir archivos de terceros, consultar sus licencias y atribuciones individuales.

## Comprobación antes de hacer público el repositorio

1. En **Code** deben aparecer las carpetas `scripts/`, `tools/`, `config/`, `docs/` y `tests/`, así como `README.md`, `LICENSE`, `.gitignore` y `SHA256SUMS.txt`.
2. Comprobar que `README.md` especifica **64 GB RAM probados; 32 GB RAM no probados ni auditados**.
3. Confirmar que los hashes actuales del código figuran en `SHA256SUMS.txt` y que el workflow está presente.
4. Revisar que no se publicaron archivos privados ni modelos; comprobar también los commits previos.
5. Cuando el titular lo decida, cambiar **Settings → Danger Zone → Change repository visibility → Public**.

No es obligatorio crear GitHub Releases ni un calendario de versiones para publicar el código y la documentación.
