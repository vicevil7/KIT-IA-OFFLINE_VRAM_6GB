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

Es una configuración **plausible para determinados módulos**, ejecutándolos de uno en uno, pero todavía **no se ha probado este kit completo con 32 GB**. Los requerimientos de RAM dependen también del modelo LLM, tamaño de contexto, offloading y aplicaciones abiertas y con 6 GB de VRAM el margen de la generación de imágenes observada es estrecho. [Guía de compatibilidad](docs/COMPATIBILIDAD_32GB_6GB.md).

## Instalación y primeros pasos

Este repositorio no incluye un instalador automático completo de los motores de IA.

1. Consultar [Instalación en Windows](docs/INSTALACION_WINDOWS.md) para conocer la estructura de carpetas y las dependencias necesarias.
2. Descargar el software y modelos originales desde sus fuentes oficiales, verificación y separación de carpetas. Consultar [Compatibilidad con 32 GB/6 GB](docs/COMPATIBILIDAD_32GB_6GB.md) antes de elegir modelos y ejecutar servicios simultáneos.
3. Consultar [uso de los scripts públicos](docs/USO_SCRIPTS_PUBLICOS.md) y [procedencia/cambios](docs/CODIGO_ORIGINAL_Y_CAMBIOS.md). 
4. Configurar la raíz de instalación mediante `KIT_IA_OFFLINE_ROOT` y el cargador de comandos, estableciendo el cargador, modelos y ejecutables por separado.
5. Preparar las configuraciones con tools/Preparar-Configuraciones.ps1.
6. Comprobar las rutas y dependencias antes de iniciar los motores.
7. Revisar [Publicación en GitHub](docs/GITHUB_PUBLICACION.md): archivos a compartir, exclusiones, licencias y requisitos para un paquete reproducible.

## Comandos de disponibles. 

Comandos personalizados en equipo origen, por lo que, en otro equipo solo deben usarse **después** de instalar dependencias y validar las variantes adaptadas:

```powershell
# Música
ia_musica on
ia_musica status
ia_musica off
# Texto a voz - Piper
ia_voz "Hola, esta es una prueba."
# Texto a voz - Kokoro
ia_kokoro "Hola, esta es una prueba." -Voz santa
# ComfyUI
ia_comfyui on
ia_comfyui status
ia_comfyui off
#Generación de imágenes
ia_imagen "Un castillo junto a un lago al amanecer"
ia_imagen "Un bosque ilustrado" -Ancho 720 -Alto 720 -Semilla 42
```
**Generación de imágenes:** ia_imagen utiliza por defecto una resolución de 1024 × 576 píxeles, semilla aleatoria y guarda los resultados en la carpeta Descargas de Windows, salvo que se indiquen otros parámetros.

En el equipo de referencia se verificó el arranque y apagado automático de ComfyUI durante la generación. Este comportamiento todavía no se ha validado con los scripts adaptados en este repositorio en una instalación nueva.

## Estructura del repositorio 

```powershell
│
├── README.md
├── LICENSE
├── .gitignore
├── SHA256SUMS.txt
│
├── config/
│   ├── ARCHIVOS_PENDIENTES.md
│   ├── ComfyUI-Z-Image-Turbo-model-paths.example.yaml
│   └── ComfyUI-Z-Image-Turbo-workflow.json
│
├── docs/
│   ├── INSTALACION_WINDOWS.md
│   ├── USO_SCRIPTS_PUBLICOS.md
│   ├── CODIGO_ORIGINAL_Y_CAMBIOS.md
│   ├── COMPATIBILIDAD_32GB_6GB.md
│   ├── GITHUB_PUBLICACION.md
│   └── VALIDACION_WINDOWS.md
│
├── scripts/
│   ├── ia_comfyui.ps1
│   ├── ia_help_extensiones.json
│   ├── ia_help_extensiones.ps1
│   ├── ia_imagen.ps1
│   ├── ia_imagen_generar.py
│   ├── ia_kokoro.ps1
│   ├── ia_musica.ps1
│   ├── ia_voz.ps1
│   └── kokoro_generar.py
│
├── tools/
│   ├── Cargar-Comandos.ps1
│   ├── Preparar-Configuraciones.ps1
│   └── Recolectar-Configuraciones.ps1
│
└── tests/
    └── validar_fuentes.py
```

Los archivos originales fueron examinados y adaptados en una copia pública, véase [validación en Windows](docs/VALIDACION_WINDOWS_2026-11-14.md). El recolector sigue siendo una herramienta opcional para obtener una copia privada, no un sistema de publicación.

## Documentación técnica

- Instalación en Windows

- Uso de los scripts públicos

- Adaptaciones del código

- Compatibilidad de hardware

- Referencias de integridad

- Publicación en GitHub

- Resultados de validación en Windows

El archivo SHA256SUMS.txt permite comprobar la integridad de los archivos incluidos en la distribución correspondiente.

## Software y proyectos de terceros

Este kit integra herramientas desarrolladas y mantenidas por sus respectivos autores.

|Software|Fuente oficial
|---|---|
Ollama |ollama.com - [Ollama](https://ollama.com/)
ComfyUI|GitHub — ComfyUI - [ComfyUI](https://github.com/Comfy-Org/ComfyUI)
ComfyUI-GGUF|GitHub — ComfyUI-GGUF - [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF)
Z-Image Turbo GGUF|Hugging Face - [Z-Image Turbo GGUF](https://huggingface.co/unsloth/Z-Image-Turbo-GGUF)
ACE-Step 1.5 |GitHub — ACE-Step - [ACE-Step 1.5](https://github.com/ace-step/ACE-Step-1.5)
Handy|GitHub — Handy - [Handy](https://github.com/cjpais/Handy)
Piper|Hugging Face — Piper Voices - [Piper voces](https://huggingface.co/rhasspy/piper-voices)
Kokoro ONNX|GitHub — Kokoro ONNX - [Kokoro ONNX](https://github.com/thewh1teagle/kokoro-onnx)

Los programas, modelos, voces, pesos, librerías e instaladores de terceros no se redistribuyen en este repositorio, conservando cada componente su propia licencia y condiciones de uso y distribución. En especial, revisar los avisos de atribución de las voces antes de redistribuirlas,  asi como enlaces y condiciones actuales antes de cualquier publicación de binarios o pesos.

## Seguridad y límites

- El funcionamiento offline fue comprobado en pruebas concretas con la conexión a Internet desconectada.
- Variables como `HF_HUB_OFFLINE=1` y parámetros similares son medidas de aplicación, que no sustituyen a un cortafuegos ni constituyen por sí mismas una garantía de aislamiento de red.
- Escuchar solo en `127.0.0.1` para las interfaces locales; no exponer puertos de inferencia a Internet sin autenticación y medidas adicionales.
- Los scripts deben revisarse antes de ejecutarse y sus dependencias descargarse de fuentes confiables.
- Los resultados de rendimiento corresponden exclusivamente al hardware y a las condiciones descritas. El modelo de imagen y su workflow no se han probado fuera del equipo descrito, pudiendo variar la configuración por un controlador, GPU y paquetes instalados.
- La instalación y el funcionamiento completo del kit público no se han verificado en un segundo equipo.

## Licencia

Los scripts de integración, herramientas y documentación original de este repositorio se distribuyen bajo la **licencia MIT**, con copyright **2026 vicevil.dev**. Consulta el archivo [`LICENSE`](LICENSE). La licencia permite usar, modificar y distribuir el material sujeto a sus condiciones, incluida la conservación del aviso de copyright y licencia.

Esta licencia se aplica únicamente al contenido que el titular está autorizado a licenciar. Los motores, modelos, voces, pesos y otros componentes de terceros conservan sus respectivas licencias y condiciones de distribución.

Los programas, modelos, voces, pesos y demás componentes de terceros **no quedan relicenciados**, y se rigen por sus propias licencias y condiciones de distribución, enlazadas en la sección anterior.
