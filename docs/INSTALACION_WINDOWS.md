# Guía de instalación para Windows 11

**Estado:** guía técnica basada en una instalación real. Los 11 archivos de configuración revisados se incluyen en este repositorio, pero **su adaptación pública y los nuevos scripts de instalación no se han probado en Windows**; no equivale a instalación automatizada completa. Referencia: 14/11/2026, 64 GB RAM / NVIDIA RTX 3060 Laptop 6 GB. Un equipo distinto requiere sus propias pruebas.

## 0. Conceptos de esta configuración

- **Fase conectada:** descargar componentes desde fuentes oficiales, confirmar sus licencias y versiones/revisiones, calcular SHA-256, guardar instaladores/ruedas/modelos.
- **Fase offline:** arrancar localmente los motores con pesos y dependencias ya presentes, sin conectar servicios de pago. Las pruebas documentadas se hicieron desconectando Internet; un programa podría tener otros comportamientos fuera de las rutas probadas.
- **Separar programas y pesos:** evitar duplicaciones y facilitar restauraciones.
- **No mezclar entornos Python:** ComfyUI incluye su Python; ACE-Step incluye su propio runtime; Piper y Kokoro se prepararon por separado.
- **Interfaces solo locales:** `127.0.0.1` para las APIs.

## 1. Preparación del equipo

1. Windows 11 actualizado; PowerShell 7; controlador NVIDIA compatible; 7-Zip. Validar `nvidia-smi`, `pwsh --version`, espacio en disco y GPU. **32 GB RAM / 6 GB VRAM aún no está probado para el kit completo.**
2. Elegir una unidad **fiable y con capacidad suficiente**, por ejemplo `D:\KIT_IA_OFFLINE`; la letra de la instalación de referencia fue F:, pero no debe copiarse indiscriminadamente. Discos externos pueden desconectarse: no usarlos como única ubicación de archivos irremplazables.
3. Guardar instaladores y pesos por **revisión** y conservar un registro SHA. Comparar contra el digest publicado por el fabricante cuando esté disponible; el hash de una descarga reciente puede diferir si upstream actualiza el fichero.
4. Desconectar la red solo **después** de descargar todos los artefactos y dependencias. No alterar firewall, antivirus ni configuración global de Python para superar errores de instalación sin investigar la causa.

Ejemplo de estructura (ejecutar únicamente en la unidad que hayas elegido):

```powershell
$KitRoot = 'D:\KIT_IA_OFFLINE'
@('00_INSTALADORES','01_MODELOS','02_APLICACIONES',
  '04_CONFIGURACIONES','05_HASHES','06_PRUEBAS') |
  ForEach-Object {
    New-Item -ItemType Directory -Path (Join-Path $KitRoot $_) -Force | Out-Null
  }
```

La instalación en F: que sirve de referencia sigue una estructura análoga. El nombre `03_...` no aparece en las carpetas conocidas; no inventamos su función.

## 2. Ollama / LLM

- Instalar [Ollama para Windows](https://ollama.com/download) y comprobar API local `http://127.0.0.1:11434`.
- En el equipo de referencia se conservaron modelos `qwen3.5:9b-q4_K_M`, `qwen3.5:4b-q4_K_M`, `qwen2.5-coder:7b` y `embeddinggemma:300m` mediante un respaldo de 32 ficheros / 14,14 GiB. No se modificó la instalación previa de Ollama.
- Elegir los modelos por RAM disponible y contexto real; que un fichero ocupe 6,6 GB no significa que el proceso necesite solo esa cantidad de memoria.
- Strata era una aplicación ya existente en el equipo de referencia y estaba integrada en el comando original `ia`; **no forma parte de una instalación automatizada de este paquete**. Su API de referencia escuchaba en `127.0.0.1:19081/v1`.

Comprobación de API, cuando el motor esté activo:

```powershell
Invoke-RestMethod 'http://127.0.0.1:11434/api/tags'
```

## 3. ACE-Step 1.5 — música

1. Descargar el portable oficial `ACE-Step-1.5.7z` desde [ACE-Step](https://github.com/ace-step/ACE-Step-1.5) según las instrucciones de instalación de esa revisión. Guardar el 7z bajo `00_INSTALADORES` y verificar el SHA de **esa** descarga.
2. Extraer a `02_APLICACIONES\ACE-Step-1.5`.
3. Descargar los pesos compatibles desde [ACE-Step/Ace-Step1.5](https://huggingface.co/ACE-Step/Ace-Step1.5). La instalación de referencia fijó revisión `19671f406d603126926c1b7e2adc169acbcade22`. El checkpoint exacto elegido importa; no convertir todos los ejemplos del repositorio en descargas obligatorias.
4. Guardar pesos en `01_MODELOS\MUSICA\ACE-Step-1.5`; configurar `checkpoints` de ACE-Step mediante una **junction NTFS solo si la ruta destino ya contiene los pesos correctos**. `New-Item -ItemType Junction` puede emplearse, pero exige revisar previamente las rutas; no enlazar encima de un directorio operativo sin respaldo.
5. Configurar el launcher para localhost `127.0.0.1:7860`, sin autoactualizaciones ni LLM auxiliar, con descarga/offload CPU si es necesario por 6 GB VRAM. **El `.env` y `.bat` exactos del equipo de referencia deben exportarse y revisarse, no reconstruirse adivinando sus variables.**
6. Arrancar y generar una prueba breve sin Internet; medir RAM/VRAM. En el equipo de referencia una prueba de música mostró ~16,35 GiB RAM y 4,02 GiB VRAM.

La función `ia_musica on|off|status` fue creada en PowerShell de referencia; **este paquete base no incluye todavía su implementación**.

## 4. Handy — dictado local

1. Descargar instalador oficial [Handy 0.10.0](https://github.com/cjpais/Handy/releases), verificar firma/código/hash de la versión elegida.
2. Instalar en modo portable según las funciones de la versión, separando carpeta de datos y ejecutable.
3. Usar **modelos GGUF compatibles con Handy 0.10.0**: Parakeet TDT v3 Q8_0, VoxLingua107 LangID F16, Whisper Medium Q8_0 (según necesidad). No sustituirlos por el Parakeet ONNX legado.
4. Desactivar comprobaciones automáticas de actualización si se necesita un funcionamiento sin Internet; revisar los demás ajustes de privacidad según uso.
5. Verificar una transcripción en español con conexión desactivada, incluyendo el micrófono real. En la referencia se usó Vulkan sobre RTX 3060.

## 5. Piper TTS — español

1. Crear un entorno Python aislado compatible; en el equipo validado se empleó `piper-tts==1.8.0` con Python 3.14 y `onnxruntime==1.31.1`.
2. Descargar y conservar las ruedas para instalación offline, con hashes publicados cuando existan. Ejemplo de instalación con wheelhouse completo y Python **ya preparado**:

```powershell
& 'D:\RUTA\A\python.exe' -m pip install --no-index --find-links 'D:\KIT_IA_OFFLINE\00_INSTALADORES\Piper-TTS-1.8.0-PY314' 'piper-tts==1.8.0'
```

3. Descargar `.onnx`, `.onnx.json` y model card de [es_ES-davefx-medium](https://huggingface.co/rhasspy/piper-voices/tree/main/es/es_ES/davefx/medium) y/o [es_ES-sharvard-medium](https://huggingface.co/rhasspy/piper-voices/tree/main/es/es_ES/sharvard/medium). La referencia fijó revisión `2f358b6a560e3a913ebf509b2f3344f20b367f94`.
4. Verificar formato WAV en 22.050 Hz, mono, PCM 16 bits tras síntesis en español. Las voces tienen **condiciones de datos de entrenamiento que pueden diferir**; conservar sus model cards y avisos de atribución.

El script público adaptado está en `scripts/ia_voz.ps1`; sigue pendiente de prueba real en otro equipo.

## 6. Kokoro ONNX — español

1. Instalar Python **3.13.17** en un directorio independiente; no modificar el Python de ComfyUI o ACE-Step ni cambiar PATH global.
2. Crear entorno virtual con `venv --copies` si las condiciones locales lo requieren.
3. Preparar wheelhouse Windows x64 Python 3.13 y instalar (desde él, sin índice si ya está descargado): `kokoro-onnx==0.6.1`, `soundfile==0.14.0` más dependencias compatibles. Versiones observadas: `onnxruntime==1.32.0`, `numpy==2.5.4`, `espeakng-loader==0.2.4`.
4. Descargar `kokoro-v1.0.onnx` y `voices-v1.0.bin` desde [model-files-v1.1](https://github.com/thewh1teagle/kokoro-onnx/releases/tag/model-files-v1.1).
5. Para español, usar fonemización `es` mediante eSpeak NG incluido en el loader y voces `em_santa`, `ef_dora`, `em_alex`. El predeterminado de la referencia fue Santa.
6. Verificar generación WAV PCM16 mono 24.000 Hz; no confundir errores de la codificación de salida de consola con errores del modelo.

## 7. ComfyUI + Z-Image Turbo Q4_K_M — imágenes

### 7.1 Instalar y aislar runtime

1. Obtener **ComfyUI v0.45.0 Windows portable NVIDIA** desde [releases de ComfyUI](https://github.com/Comfy-Org/ComfyUI/releases), o verificar compatibilidad si se elige otra versión. En la referencia el archivo tenía SHA `60C12E8C7AF778047AD0413722DD3DC0F6CA773A41CBF5CB229EE9BC92C44A6F`.
2. Extraer a `02_APLICACIONES\ComfyUI\ComfyUI_windows_portable`.
3. Usar su Python integrado (`python_embeded\python.exe`) y comprobar `import torch; torch.cuda.is_available()` sin instalar otro PyTorch en el equipo.
4. Instalar el nodo [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF) desde una revisión confiable y fijada: la instalación real probada usó commit `6ea2651e7df66d7585f6ffee804b20e92fb38b8a`; `gguf==0.19.0`, `protobuf==7.36.2`. **Los requisitos completos del nodo y otros paquetes deben consultarse en el commit exacto; no basta instalar solo los dos paquetes citados.**
5. Comprobar presencia de `UnetLoaderGGUF` en `http://127.0.0.1:8188/object_info/UnetLoaderGGUF` después del arranque.

### 7.2 Poner modelos en carpetas separadas

```text
D:\KIT_IA_OFFLINE\01_MODELOS\IMAGENES\Z-Image-Turbo\
  diffusion_models\z-image-turbo-Q4_K_M.gguf
  text_encoders\qwen_3_4b_fp4_mixed.safetensors
  vae\ae.safetensors
```

Modelo principal desde [unsloth/Z-Image-Turbo-GGUF](https://huggingface.co/unsloth/Z-Image-Turbo-GGUF), **revisión probada `b40f712c569ecfff42f2307dcc43399ae1d71318`** y SHA-256 `4AB6BCEB1F0B82C9E725F123848018EAC662A6FC1D467C019E13E701AFB7B55C`; **3.671,77 MiB** en el equipo de referencia. **No sustituir el enlace por `main` sin comprobar tamaño/hash**, ya que el contenido servido podría variar.

Los dos pesos auxiliares proceden de **[Comfy-Org/Z-Image-Turbo](https://huggingface.co/Comfy-Org/Z-Image-Turbo)**, revisión probada `6fc90a3b1b653e935a0d175e260736de25b84df5`:

- [Encoder `qwen_3_4b_fp4_mixed.safetensors`](https://huggingface.co/Comfy-Org/Z-Image-Turbo/blob/6fc90a3b1b653e935a0d175e260736de25b84df5/split_files/text_encoders/qwen_3_4b_fp4_mixed.safetensors), **3.318,23 MiB** y SHA-256 oficial `7CA32DCF07DFE7692945D80FFF86E3A74CB83C6206B9B223AC6836B939BB85D6`.
- [VAE `ae.safetensors`](https://huggingface.co/Comfy-Org/Z-Image-Turbo/blob/6fc90a3b1b653e935a0d175e260736de25b84df5/split_files/vae/ae.safetensors), **319,77 MiB** y SHA-256 oficial `AFC8E28272CD15DB3919BACDB6918CE9C1ED22E96CB12C4D5ED0FBA823529E38`.

En el historial de instalación se comunicó comprobación de integridad respecto a los metadatos oficiales. **Revisar los registros originales de `05_HASHES` y la versión exacta antes de reutilizar pesos o introducir cambios**.

El comando `tools/Preparar-Configuraciones.ps1 -KitRoot ... -Aplicar` genera `04_CONFIGURACIONES\ComfyUI-Z-Image-Turbo-model-paths.yaml` con la raíz escogida; la plantilla `config/ComfyUI-Z-Image-Turbo-model-paths.example.yaml` sirve de muestra. La herramienta de preparación aún está pendiente de prueba Windows.

### 7.3 Arranque del motor

Desde el directorio portable, con el Python integrado, utilizar el equivalente a:

```powershell
$Root = 'D:\KIT_IA_OFFLINE'
$Portable = Join-Path $Root '02_APLICACIONES\ComfyUI\ComfyUI_windows_portable'
$Config = Join-Path $Root '04_CONFIGURACIONES\ComfyUI-Z-Image-Turbo-model-paths.yaml'
Push-Location $Portable
try {
  & '.\python_embeded\python.exe' -s '.\ComfyUI\main.py' `
    --listen '127.0.0.1' --port 8188 --lowvram --offline `
    --disable-auto-launch --disable-assets --windows-standalone-build `
    --extra-model-paths-config $Config
} finally { Pop-Location }
```

Ese comando **deja ComfyUI abierto en primer plano** hasta detenerlo normalmente; no proporciona el gestor `ia_comfyui` con control PID validado. Cerrar la consola de forma brusca durante escrituras no es un procedimiento de recuperación. Probar primero que la interfaz y API responden localmente. Para funcionamiento offline real, comprobar que los modelos, paquetes y nodos no intentan descargarse al iniciar.

### 7.4 Workflow original incluido

La referencia utilizó **10 nodos / 10 enlaces**, 8 steps, CFG 1, sampler `res_multistep`, scheduler `simple`, shift AuraFlow 3 y texto Lumina2. El JSON verificado tiene SHA:

```text
6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C
```

El fichero original **sí está incluido** como `config/ComfyUI-Z-Image-Turbo-workflow.json` y conserva ese SHA. La preparación lo copiará a `04_CONFIGURACIONES` sin sobrescribir versiones diferentes.

### 7.5 `ia_imagen` — interfaz final de referencia

En el equipo original se implementaron `ia_comfyui on|off|status` y `ia_imagen "prompt"`, con parámetros `-Ancho`, `-Alto`, `-Semilla`, `-Carpeta`, `-Salida`. Comportamiento observado:

- Default **1024×576**, 8 pasos, CFG 1, semilla aleatoria, Descargas Windows; `-Semilla 42` fija semilla, `-Semilla -1` la aleatoriza.
- Los valores de ancho y alto deben ser múltiplos de 16, entre 256 y 1024 en la implementación actual.
- Si el servidor se ha iniciado desde el mismo gestor, al finalizar genera PNG y apaga ComfyUI sin interferir con procesos ajenos; el helper utiliza una verificación de estado PID/puerto.
- El flujo final mostró **5,42 GB de VRAM** de pico, **24,1 segundos de generación** y **45,68 segundos de comando total** en una sola ejecución de referencia.

Se incluyen las versiones públicas adaptadas de los scripts originales en `scripts/`. Requieren pruebas en Windows; consulta `docs/USO_SCRIPTS_PUBLICOS.md`. No confundas esta guía con un instalador unificado.

## 8. Qué probar con Internet desconectado

1. `nvidia-smi` y Python de ComfyUI con `torch.cuda.is_available()==True`.
2. Ollama API local y respuesta del modelo que se vaya a usar.
3. ACE-Step, un audio de prueba, consumo RAM/VRAM y parada correcta.
4. Handy, transcripción de una frase real en español.
5. Piper, WAV PCM16 22.050 Hz; Kokoro, WAV PCM16 24.000 Hz.
6. ComfyUI, API 8188, `UnetLoaderGGUF` y un PNG 1024×576 con hash local.
7. Con los scripts públicos adaptados: `ia_ayuda` (18 ejemplos), carga en sesión PowerShell nueva y `ia_imagen` con encendido/apagado seguro. Pendiente de prueba en Windows.
8. No ejecutar todos los motores simultáneamente al intentar validar equipos con poca RAM.

## 9. Mantenimiento y recuperación

- Mantener los pesos y sus hashes fuera de repositorio Git. Registrar revisiones, versiones, tamaños y proveniencia.
- Antes de actualizar, guardar copia verificable de scripts y configuraciones; no duplicar modelos por defecto.
- Si cambias la unidad, editar rutas absolutas del YAML y scripts; idealmente cambiar a ruta raíz configurable en la futura versión pública.
- Conservar al menos una copia adicional de archivos esenciales en un soporte fiable diferente. No dejar datos únicos en una unidad que presente eventos de E/S.
- Si Windows registra 129/153 o el dispositivo desaparece, **no concluir que ComfyUI o ACE-Step son la causa**; comprobar almacenamiento USB, disco SATA, cables, controladora y alimentación.

## 10. Condiciones para llamar «reproducible» a la publicación

No anunciar instalación completa hasta **probar en Windows los scripts adaptados**, la preparación del YAML, el workflow y la instalación en otro ordenador. Los pesos auxiliares y hashes provienen de la instalación de referencia; deben verificarse contra sus fuentes al descargar. El paquete incluye código y documentación, pero no pesos ni programas de terceros.

Fuentes directas: [ComfyUI](https://github.com/Comfy-Org/ComfyUI), [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF), [Z-Image](https://huggingface.co/unsloth/Z-Image-Turbo-GGUF), [ACE-Step](https://github.com/ace-step/ACE-Step-1.5), [Handy](https://github.com/cjpais/Handy), [Piper](https://huggingface.co/rhasspy/piper-voices), [Kokoro](https://github.com/thewh1teagle/kokoro-onnx), [Ollama](https://ollama.com).
