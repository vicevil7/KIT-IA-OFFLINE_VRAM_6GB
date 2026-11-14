# KIT IA Offline — laboratorio de IA local para Windows

Herramientas, scripts y documentación para integrar inteligencia artificial local en Windows, incluyendo modelos de lenguaje (LLM), generación de imágenes, música, transcripción de voz y síntesis de voz.

El proyecto está orientado a utilizar herramientas de IA en un entorno local, sin depender de servicios remotos de inferencia durante su funcionamiento offline.

**Estado de publicación:** **Aún no se han ejecutado los motores con el código adaptado ni se ha probado en un segundo equipo**. No contiene motores, modelos ni instalador automático. Consulta [uso de los scripts](docs/USO_SCRIPTS_PUBLICOS.md).

## Estado del proyecto

El repositorio contiene scripts PowerShell, herramientas Python, configuraciones y documentación para integrar diferentes motores de IA en Windows.

**Validaciones realizadas en Windows 11:**

- Análisis de sintaxis de los 9 scripts PowerShell públicos, sin errores.

- Preparación de 11 archivos de configuración en un directorio aislado.

- Generación de un YAML con rutas adaptables.

- Carga de 6 funciones en PowerShell sin perfil.

- Comprobación de la ayuda con 18 ejemplos de comandos.

- Verificación de que la preparación no modificó la instalación original.

## Qué contiene el proyecto

| Función | Herramienta | Estado en equipo de referencia |
|---|---|---|
| Chat y programación LLM | Ollama + gestor PowerShell con integración Strata existente | Instalación local utilizada y copia de modelos Ollama verificada |
| Generación de Música | ACE-Step 1.5 | Generación offline validada |
|Transcripción de voz | Handy 0.10.0 + modelos GGUF | Transcripción offline validada |
| Síntesis de voz en español | Piper TTS 1.8.0 | Voces `DaveFX` y `Sharvard` validados |
| Texto a voz, español | Kokoro ONNX 0.6.1 | Voces `Santa, Dora y Alex` validados |
| Generación de imágenes | ComfyUI v0.45.0 + ComfyUI-GGUF + Z-Image Turbo Q4_K_M | Generación y apagado offline validados |
| Gestión mendiante PowerShell | Comandos personalizados y creados `ia_*` en PowerShell | Funciones públicas cargadas y ayuda comprobada||

`Alcance:` este repositorio proporciona los scripts de integración y sus configuraciones. Los motores y modelos deben obtenerse e instalarse por separado.

## Hardware de referencia y compatibilidad

Las pruebas funcionales se realizaron con:

| Componente | Configuración|
|---|---|
Sistema operativo|Windows 11
Memoria RAM |64 GB
Tarjeta gráfica |NVIDIA RTX 3060 Laptop
Memoria gráfica |6 GB VRAM
PowerShell |7.6.9

## Resultados de generación de imágenes

En el equipo de referencia se utilizó Z-Image Turbo con:

- Resolución predeterminada: 1024 × 576 píxeles.

- Pasos de generación: 8.

- CFG: 1.

- Modo ComfyUI: --lowvram.

- Tiempo de generación observado: 24,1 segundos.

- Tiempo total del comando: 45,68 segundos, incluyendo arranque y cierre.

- Pico observado de VRAM: 5,42 GB.

Estos resultados corresponden a una prueba concreta y no constituyen una garantía de rendimiento en otros equipos.

### ¿Puede funcionar con 32 GB de RAM y una GPU de 6 GB?

Es una configuración **plausible para determinados módulos**, ejecutándolos de uno en uno, pero todavía **no se ha probado este kit completo con 32 GB**. Los requerimientos de RAM dependen también del modelo LLM, tamaño de contexto, offloading y aplicaciones abiertas. Con 6 GB de VRAM el margen de la generación de imágenes observada es estrecho. [Guía de compatibilidad](docs/COMPATIBILIDAD_32GB_6GB.md).

## Instalación y primeros pasos

Este repositorio no incluye un instalador automático completo de los motores de IA.

1. Consultar [Instalación en Windows](docs/INSTALACION_WINDOWS.md) para conocer la estructura de carpetas y las dependencias necesarias. 2. Descargar el software y modelos originales desde sus fuentes oficiales, verificación y separación de carpetas. Consultar [Compatibilidad con 32 GB/6 GB](docs/COMPATIBILIDAD_32GB_6GB.md) antes de elegir modelos y ejecutar servicios simultáneos.
3. Consultar [uso de los scripts públicos](docs/USO_SCRIPTS_PUBLICOS.md) y [procedencia/cambios](docs/CODIGO_ORIGINAL_Y_CAMBIOS.md). 
4. Configurar la raíz de instalación mediante KIT_IA_OFFLINE_ROOT y el cargador de comandos.
5. Configurar la raíz de instalación mediante `KIT_IA_OFFLINE_ROOT` y el cargador de comandos, estableciendo el cargador, modelos y ejecutables por separado.
6. Comprobar las rutas y dependencias antes de iniciar los motores.
7. Revisar [Publicación en GitHub](docs/GITHUB_PUBLICACION.md): archivos a compartir, exclusiones, licencias y requisitos para un paquete reproducible.

## Comandos de disponibles. 

Comandos personalizados en equipo origen, por lo que, en otro equipo solo deben usarse **después** de instalar dependencias y validar las variantes adaptadas:

**Ayuda de los comandos públicos**
ia_ayuda

# Música
ia_musica on
ia_musica status
ia_musica off

# Texto a voz con Piper
ia_voz "Hola, esta es una prueba."

# Texto a voz con Kokoro
ia_kokoro "Hola, esta es una prueba." -Voz santa

# ComfyUI
ia_comfyui on
ia_comfyui status
ia_comfyui off

# Generación de imágenes
ia_imagen "Un castillo junto a un lago al amanecer"

ia_imagen "Un bosque ilustrado" -Ancho 720 -Alto 720 -Semilla 42

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
