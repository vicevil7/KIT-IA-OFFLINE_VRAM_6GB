# Hardware de referencia y límites de compatibilidad

**Fecha de las pruebas documentadas:** 14 de noviembre de 2026.

## Configuración que sí se utilizó

- **Windows 11, 64 GB de RAM y NVIDIA RTX 3060 Laptop con 6 GB de VRAM.**
- Pruebas reales de generación de música, voz, dictado e imágenes sobre el equipo de referencia con las instalaciones originales.
- Para Z-Image Turbo Q4_K_M a **1024 × 576**, se registró un pico global aproximado de **5,42 GB de VRAM**, **24,1 s** de generación y **45,68 s** de duración total del comando en una ejecución concreta.
- Una generación musical de 60 segundos con ACE-Step registró aproximadamente **16,35 GiB de RAM** y **4,02 GiB de VRAM**. Estas cifras corresponden a esa ejecución, no a mínimos certificados.
- **No se ha validado ejecutar todos los motores simultáneamente.**

## 32 GB de RAM: NO PROBADO NI AUDITADO

**[No verificado] No se ha probado ni auditado este proyecto con 32 GB de RAM.** No existen pruebas de instalación, generación, rendimiento, estabilidad ni mediciones de consumo de RAM efectuadas en ese hardware.

En consecuencia:

- **No se afirma compatibilidad** con 32 GB, ni del kit completo ni de ningún módulo específico ejecutado bajo esa configuración.
- **No se publica un mínimo recomendado o certificado de 32 GB de RAM.**
- No se extrapolan los resultados de 64 GB para prometer funcionamiento, tiempos de ejecución ni estabilidad con 32 GB.
- Una posible ejecución en 32 GB constituye únicamente una hipótesis técnica sin pruebas realizadas. Tampoco se ha efectuado una auditoría de compatibilidad para esa memoria.

La GPU de **6 GB de VRAM sí se utilizó en las pruebas de referencia**, pero esto no valida por sí mismo una combinación con menos memoria RAM, otra GPU o controladores diferentes.

## Alcance del código publicado

Los scripts públicos incorporan adaptaciones de rutas para utilizar `KIT_IA_OFFLINE_ROOT`. Se verificaron la sintaxis de nueve scripts PowerShell, la preparación aislada de once configuraciones, la carga de seis funciones y dieciocho ejemplos de ayuda en Windows 11. **No se ejecutaron los motores a través de los scripts adaptados y no se realizó una instalación limpia en un segundo ordenador.**

Consulta [la evidencia de validación](VALIDACION_WINDOWS_2026-11-14.md). El repositorio describe una instalación real de referencia y publica sus integraciones, no una certificación de compatibilidad para otras configuraciones.
