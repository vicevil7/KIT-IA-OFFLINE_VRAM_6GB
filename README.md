# KIT IA Offline — laboratorio de IA local para Windows

**Guía y código de integración para Windows (versión preliminar; validación de preparación/carga realizada en Windows 11, no probado en un segundo equipo)** para integrar LLM locales, generación de imágenes, música, dictado y síntesis de voz en un PC Windows, sin depender de servicios de inferencia remotos durante las pruebas offline descritas.

> **Estado de publicación:** integra los 11 archivos originales auditados, con scripts PowerShell y Kokoro adaptados a una raíz configurable. Los nueve scripts PowerShell públicos pasaron el análisis de sintaxis en PowerShell 7 de Windows. La preparación de 11 configuraciones y la carga de seis funciones se comprobaron en una carpeta simulada de E:, sin arrancar motores. **Aún no se han ejecutado los motores con el código adaptado ni se ha probado en un segundo equipo**. No contiene motores, modelos ni instalador automático. Consulta [uso de los scripts](docs/USO_SCRIPTS_PUBLICOS.md).

## Qué contiene el proyecto

| Función | Herramienta | Estado en equipo de referencia |
|---|---|---|
| Chat y programación LLM | Ollama + gestor PowerShell; integración Strata existente | Instalación previa utilizada; copia de modelos Ollama verificada |
| Música | ACE-Step 1.5 | Generación offline validada |
| Dictado / voz a texto | Handy 0.10.0 + modelos GGUF | Transcripción offline validada |
| Texto a voz, español | Piper TTS 1.8.0 | DaveFX y Sharvard validados |
| Texto a voz, español | Kokoro ONNX 0.6.1 | Santa, Dora y Alex validados |
| Imagen | ComfyUI v0.45.0 + ComfyUI-GGUF + Z-Image Turbo Q4_K_M | Generación y apagado offline validados |
| Acceso cómodo | Comandos `ia_*` en PowerShell | `ia help` con 18 ejemplos verificados en el equipo original; `ia_ayuda` en el público |

**No incluido en esta distribución:** Kiwix u otros paquetes de contenido de consulta offline; estaban contemplados como fase futura.

## Hardware de referencia y compatibilidad

Pruebas realizadas en **Windows 11, 64 GB RAM y NVIDIA RTX 3060 Laptop de 6 GB VRAM**, con PowerShell 7.6.9. Para Z-Image Turbo se emplearon 8 pasos, CFG 1, `--lowvram` y resolución predeterminada **1024 × 576**. Un PNG completo tardó **24,1 s** en la fase de generación y **45,68 s** para el comando total (arranque y cierre incluidos); pico observado de VRAM **5,42 GB**.

### ¿Puede funcionar con 32 GB de RAM y una GPU de 6 GB?

**[No verificado]** Es una configuración **plausible para determinados módulos**, ejecutándolos de uno en uno, pero todavía **no se ha probado este kit completo con 32 GB**. Los requerimientos de RAM dependen también del modelo LLM, tamaño de contexto, offloading y aplicaciones abiertas. Con 6 GB de VRAM el margen de la generación de imágenes observada es estrecho. [Guía de compatibilidad](docs/COMPATIBILIDAD_32GB_6GB.md).

## Empezar

1. Leer [Instalación en Windows](docs/INSTALACION_WINDOWS.md): descarga de software y modelos originales desde sus fuentes oficiales, verificación y separación de carpetas.
2. Consultar [Compatibilidad con 32 GB/6 GB](docs/COMPATIBILIDAD_32GB_6GB.md) antes de elegir modelos y ejecutar servicios simultáneos.
3. Revisar [Publicación en GitHub](docs/GITHUB_PUBLICACION.md): archivos a compartir, exclusiones, licencias y requisitos para un paquete reproducible.
4. Consultar [uso de los scripts públicos](docs/USO_SCRIPTS_PUBLICOS.md) y [procedencia/cambios](docs/CODIGO_ORIGINAL_Y_CAMBIOS.md). Establecer `KIT_IA_OFFLINE_ROOT` mediante el cargador; instalar modelos y ejecutables por separado.

Comandos de la instalación de referencia. En otro equipo solo deben usarse **después** de instalar dependencias y validar las variantes adaptadas:

```powershell
ia_ayuda
# ia help e ia status dependen del gestor preexistente Strata/Ollama
ia_musica on
ia_musica status
ia_musica off
ia_voz "Hola, esta es una prueba."
ia_kokoro "Hola, esta es una prueba." -Voz santa
ia_comfyui on
ia_comfyui status
ia_comfyui off
ia_imagen "Un castillo junto a un lago al amanecer"
ia_imagen "Un bosque ilustrado" -Ancho 720 -Alto 720 -Semilla 42
```

> `ia_imagen` guarda en Descargas de Windows por defecto. En la instalación probada, iniciaba ComfyUI de forma automática si estaba apagado y lo detenía al finalizar; la configuración definitiva genera 1024×576 con semilla aleatoria, salvo que se especifiquen argumentos.

## Estructura del repositorio actualizado

```text
README.md
LICENSE
.gitignore
config/
  ComfyUI-Z-Image-Turbo-model-paths.example.yaml
  ComfyUI-Z-Image-Turbo-workflow.json
  ARCHIVOS_PENDIENTES.md
docs/
  INSTALACION_WINDOWS.md
  USO_SCRIPTS_PUBLICOS.md
  CODIGO_ORIGINAL_Y_CAMBIOS.md
  COMPATIBILIDAD_32GB_6GB.md
  HASHES_REFERENCIA.md
  GITHUB_PUBLICACION.md
  VALIDACION_WINDOWS_2026-11-14.md
scripts/
  ia_musica.ps1, ia_voz.ps1, ia_kokoro.ps1
  ia_comfyui.ps1, ia_imagen.ps1, ia_help_extensiones.ps1
  kokoro_generar.py, ia_imagen_generar.py, ia_help_extensiones.json
tools/
  Preparar-Configuraciones.ps1
  Cargar-Comandos.ps1
  Recolectar-Configuraciones.ps1
tests/
  validar_fuentes.py
```

Los archivos originales fueron examinados y adaptados en una copia pública. **La prueba realizada en Windows valida preparación, carga y ayuda, no la generación real ni la instalación de dependencias**. Véase [validación en Windows](docs/VALIDACION_WINDOWS_2026-11-14.md). El recolector sigue siendo una herramienta opcional para obtener una copia privada, no un sistema de publicación.

## Fuentes del software (terceros)

- [Ollama](https://ollama.com/) · [ComfyUI](https://github.com/Comfy-Org/ComfyUI) · [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF)
- [Z-Image Turbo GGUF](https://huggingface.co/unsloth/Z-Image-Turbo-GGUF) · [ACE-Step 1.5](https://github.com/ace-step/ACE-Step-1.5)
- [Handy](https://github.com/cjpais/Handy) · [Piper voces](https://huggingface.co/rhasspy/piper-voices) · [Kokoro ONNX](https://github.com/thewh1teagle/kokoro-onnx)

Cada programa y modelo conserva su propia licencia. **No se redistribuyen los instaladores, librerías, modelos, voces ni pesos** dentro de este repositorio. En especial, revisar los avisos de atribución de las voces antes de redistribuirlas. Consultar enlaces y condiciones actuales antes de cualquier publicación de binarios o pesos.

## Seguridad y límites

- El funcionamiento offline fue comprobado en pruebas concretas con la conexión a Internet desconectada. `HF_HUB_OFFLINE=1` y parámetros similares son medidas de aplicación, **no un cortafuegos**.
- Escuchar solo en `127.0.0.1` para las interfaces locales; no exponer puertos de inferencia a Internet sin autenticación y medidas adicionales.
- No ejecutar scripts descargados sin revisarlos. Verificar origen, firmas y SHA-256 donde existan.
- El modelo de imagen y su workflow no se han probado fuera del equipo descrito. La configuración puede variar por controlador, GPU y paquetes instalados.
- La documentación original contiene una incidencia de hardware USB del equipo de referencia; no forma parte de los requisitos del kit ni debe atribuirse al software de IA.

## Licencia

Los scripts de integración, herramientas y documentación original de este repositorio se distribuyen bajo la **licencia MIT**, con copyright **2026 vicevil.dev**. Consulta el archivo [`LICENSE`](LICENSE). La licencia permite usar, modificar y distribuir el material sujeto a sus condiciones, incluida la conservación del aviso de copyright y licencia.

**Importante:** la MIT de este repositorio solo cubre el material que el titular está autorizado a licenciar. Los programas, modelos, voces, pesos y demás componentes de terceros **no** quedan relicenciados: se rigen por sus propias licencias y condiciones de distribución, enlazadas en la sección anterior.

*Documentación de estado: 14 de noviembre de 2026. Paquete preliminar de integración; no instalador completo.*
