# Compatibilidad: ¿32 GB de RAM y una GPU de 6 GB de VRAM?

**Fecha:** 14/11/2026 · **Resultado:** **NO VERIFICADO para el kit completo**. El equipo de prueba tenía **64 GB de RAM**, Windows 11 y una **RTX 3060 Laptop con 6 GB de VRAM**.

## Resumen por motor

| Parte del kit | Dato realmente comprobado | Evaluación para 32 GB RAM / 6 GB VRAM |
|---|---|---|
| Ollama Qwen3.5 4B Q4 | Instalación previa y respaldo | **[Inferencia]** Candidato razonable para probar; medir memoria y contexto en ese equipo |
| Ollama Qwen2.5 Coder 7B | Instalación previa y respaldo | **[Inferencia]** Posible, depende de offload y tamaño de contexto |
| Ollama Qwen3.5 9B Q4 | Pesos ~6,6 GB, backup verificado | **[Inferencia]** Posible con RAM; no asumir que 6 GB de VRAM bastan para cargarlo completo |
| Strata / Qwen3.8 Flash Next IQ2_XS y contexto 64K | Existente en configuración previa | **[No verificado]** Se desconoce el pico de RAM real en esta combinación; probar con contexto menor |
| ACE-Step 1.5 | ~16,35 GiB RAM y ~4,02 GiB VRAM en generación concreta de 60 s | **[Inferencia]** Factible probar con 32 GB si no se ejecutan más motores y se deja margen para Windows |
| Handy GGUF | Dictado real offline, Vulkan sobre RTX 3060 6 GB | **[Inferencia]** Plausible; medir uso de RAM/VRAM y comportamiento del micro |
| Piper TTS 1.8 | Generaciones españolas WAV reales | **[Inferencia]** Candidato de baja exigencia relativa; el pico RAM no fue medido |
| Kokoro ONNX 0.6.1 | Generaciones españolas WAV reales | **[Inferencia]** Plausible; el pico RAM no fue medido |
| ComfyUI Z-Image Turbo Q4_K_M a 1024×576 | **5,42 GB pico global VRAM**; 24,1 s de generación | **[No verificado con 32 GB RAM]** GPU de 6 GB sí probada, pero falta medir el pico de RAM y comprobar comportamiento con 32 GB |

**No son requisitos mínimos certificados.** La tabla distingue datos observados y extrapolaciones. El tamaño de los pesos en disco no es equivalente a RAM ni a VRAM requerida al ejecutarlos.

## Por qué los 6 GB de VRAM son un límite práctico

La imagen de referencia a 1024×576 consumió un pico global de **5,42 GB**; deja **~0,58 GB respecto a 6 GB nominales**, pero ese cálculo es aproximado porque la medición procede de Task Manager y puede variar con el controlador y otros procesos. Mantener `--lowvram` y cerrar juegos, navegador acelerado y otros motores durante la generación.

La resolución **1280×720** tiene **56,25 % más píxeles** que 1024×576. Eso **no implica** 56,25 % más VRAM, porque parte de la memoria la ocupan pesos, caché y buffers. No está habilitada en el comando `ia_imagen` actual, que acepta dimensiones hasta 1024 y múltiplos de 16.

Para comparar dos ejecuciones, anotar: controlador NVIDIA, versión PyTorch/CUDA, resolución, modelo cuantizado, sampler, pasos, VRAM máxima y tiempo desde la petición, y desde arranque en frío.

## Cómo validar 32 GB sin arriesgar archivos

1. Trabajar sobre un disco sano, con espacio libre suficiente y copia de scripts/configuraciones. No hacer pruebas de rendimiento usando una estación USB que está registrando errores de E/S.
2. Comprobar RAM libre antes de iniciar un motor y cerrar los demás (`ia_musica off`, `ia_comfyui off` solo para instancias gestionadas y verificadas).
3. Probar **un motor cada vez**, con la configuración que ya ha funcionado en el equipo de 64 GB.
4. Comenzar con LLM más ligeros y contextos razonables; subir complejidad solo cuando se midan memoria y estabilidad.
5. Para Z-Image, probar **1024×576**, 8 pasos y CFG 1, sin cambiar modelos, y registrar pico de RAM del sistema, VRAM global, tiempos, proceso y código de salida. No aumentar resolución antes de tener esos datos.
6. Para ACE-Step, comenzar con una duración moderada, con offload CPU según configuración y verificar que no aparezca uso excesivo de memoria virtual.
7. Comprobar apagado correcto y liberación de puertos 8188/7860. Registrar fallos y tiempos de espera.
8. Solo después de resultados repetibles en el equipo de 32 GB cambiar la etiqueta de compatibilidad de **[No verificado]** a **Verificado en hardware específico**.

Comandos útiles de lectura, opcionales:

```powershell
# Memoria física libre/total, valor instantáneo
Get-CimInstance Win32_OperatingSystem |
  Select-Object TotalVisibleMemorySize,FreePhysicalMemory

# GPU disponible, controlador y consumo instantáneo
nvidia-smi

# Espacio y disponibilidad del volumen de modelos
Get-Volume | Where-Object DriveLetter -in @('D','F') |
  Select-Object DriveLetter,HealthStatus,SizeRemaining
```

Estos comandos **no sustituyen** un monitor de picos ni demuestran que el sistema esté estable. Para la RAM de la generación de imágenes original **no hay medición final disponible**: no fabricar números para completar una tabla.

## Perfiles de uso prudentes

- **32 GB y 6 GB VRAM:** comenzar con Piper/Kokoro/Handy o LLM pequeños; comprobar Z-Image de uno en uno. La simultaneidad no está probada.
- **64 GB y 6 GB VRAM:** configuración del laboratorio probado. Z-Image 1024×576 y ACE-Step funcionaron en pruebas separadas.
- **6 GB VRAM con juego abierto o muchas pestañas:** reservar margen, no prometer que el flujo de imagen que rozó 5,42 GB seguirá funcionando al mismo tiempo.

## Información externa frente a esta instalación

La documentación oficial de ComfyUI describe soporte de GPUs con poca VRAM y tecnologías de offloading, pero eso **no acredita por sí solo** el requisito de RAM de esta combinación concreta de tres pesos Z-Image + workflow + nodos GGUF. Fuente: https://github.com/Comfy-Org/ComfyUI.

**Conclusión:** **32 GB es una opción razonable para ensayar, no un mínimo verificado.** Para publicar compatibilidad con esa memoria, primero realizar las mediciones indicadas.


> **Nota sobre el código público:** el cambio a `KIT_IA_OFFLINE_ROOT` solo afecta a rutas; no reduce el consumo de RAM/VRAM. Se ha validado la preparación/carga en PowerShell 7, pero no se han ejecutado benchmarks con este código adaptado.
