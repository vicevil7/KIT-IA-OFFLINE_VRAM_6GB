# Hashes SHA-256 y versiones de referencia

**Origen de estos datos:** resultados de verificación de la instalación del 14/11/2026. Son referencias para **esas versiones/archivos exactos**, no hashes universales de un programa o nombre de modelo. Comprobar contra metadatos publicados por el propietario del componente cuando se descargue una revisión distinta.

| Artefacto exacto | SHA-256 registrado |
|---|---|
| `ACE-Step-1.5.7z` | `25402ADB2A852A8792D0B562AF7E9C7C5F84F35503542E0586FB6C033193E486` |
| `Handy_0.10.0_x64-setup.exe` | `D4C02386D6B4B2A8EF8E53A7CE5C6C417D554005E91B3529DEF3920E0E786D03` |
| `Python-3.13.17-amd64.exe` | `5DA012101BA2E17113A9A1CD901E9CE1441086F2B7ECB5DE06EC94163899A190` |
| `ComfyUI-v0.45.0-nvidia.7z` | `60C12E8C7AF778047AD0413722DD3DC0F6CA773A41CBF5CB229EE9BC92C44A6F` |
| `Parakeet-TDT-v3-Q8_0.gguf` | `5859F77944EFCD8EAFA23A6350731960B2B55B2203DF51F319665C807D802CC7` |
| `VoxLingua107-LangID-F16.gguf` | `1F4F1A8279A3BF6EEF63FF1FE2B6E5328ADB184D43CACAB55557592B6197530E` |
| `Whisper-Medium-Q8_0.gguf` | `09E6A65E7DE377AA5B10BAE24608BC6F8CA2ED04B3993EF10D4A02BCD9A82ADF` |
| Piper DaveFX `es_ES-davefx-medium.onnx` | `D2C9224E122321AAC3C33343957FFF4D0F465226CB74C66B0F520CA3F8C0DD07` |
| Kokoro `kokoro-v1.0.onnx` | `BEB0D1848DEE9A49DA392CC3DF26958D46CFA35D321EDF434F52949153F0DF3A` |
| Kokoro `voices-v1.0.bin` | `BCA610B8308E8D99F32E6FE4197E7EC01679264EFED0CAC9140FE9C29F1FBF7D` |
| Z-Image Turbo `z-image-turbo-Q4_K_M.gguf` · Unsloth `b40f712c569ecfff42f2307dcc43399ae1d71318` | `4AB6BCEB1F0B82C9E725F123848018EAC662A6FC1D467C019E13E701AFB7B55C` |
| Z-Image texto `qwen_3_4b_fp4_mixed.safetensors` · Comfy-Org `6fc90a3b1b653e935a0d175e260736de25b84df5` | `7CA32DCF07DFE7692945D80FFF86E3A74CB83C6206B9B223AC6836B939BB85D6` (fuente oficial) |
| Z-Image VAE `ae.safetensors` · Comfy-Org `6fc90a3b1b653e935a0d175e260736de25b84df5` | `AFC8E28272CD15DB3919BACDB6918CE9C1ED22E96CB12C4D5ED0FBA823529E38` (fuente oficial) |
| `ia_imagen.ps1` **final** | `FD2A1AC997EEA345287F64C430A2E84C5C7E218ADE4B6E0554283D5C0A5036B5` |
| `ia_imagen_generar.py` **final** | `7F4FB5CF979718D2BC6EFCC37DB141908A605FC14FAD8D9191902286E103DD2C` |
| `ia_help_extensiones.json` **final, 18 ejemplos** | `EBE6F096CBE8F107BF2FC1EAB3018E2635438039E1808BB5EBCDF897772BB628` |
| `ComfyUI-Z-Image-Turbo-workflow.json` **final** | `6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C` |

El SHA del GGUF y las revisiones quedaron recuperados de resultados históricos de la instalación. Los hashes del encoder y VAE se contrastaron con las fichas oficiales, aunque es recomendable **releer los registros originales de `05_HASHES` antes de integrar ficheros binarios**. No usar el puntero mutable `main` para declarar reproducibilidad: fijar los commits indicados y volver a verificar tamaños y SHA. En páginas sin revisión fija pueden verse tamaños diferentes para un mismo nombre de archivo.

### Revisiones de repositorios

| Componente | Revisión registrada |
|---|---|
| ACE-Step/Ace-Step1.5 pesos | `19671f406d603126926c1b7e2adc169acbcade22` |
| rhasspy/piper-voices | `2f358b6a560e3a913ebf509b2f3344f20b367f94` |
| city96/ComfyUI-GGUF | `6ea2651e7df66d7585f6ffee804b20e92fb38b8a` |
| ComfyUI portable | `v0.45.0` |
| unsloth/Z-Image-Turbo-GGUF | `b40f712c569ecfff42f2307dcc43399ae1d71318` |
| Comfy-Org/Z-Image-Turbo (encoder / VAE) | `6fc90a3b1b653e935a0d175e260736de25b84df5` |
| Kokoro ONNX modelos | release `model-files-v1.1` |

### Cómo comprobar un fichero local

```powershell
Get-FileHash -LiteralPath 'D:\ruta\fichero.ext' -Algorithm SHA256
```

`Get-FileHash` tiene que leerse del archivo **real**. No ejecutar verificaciones repetidas de muchos gigabytes en un dispositivo que presenta reintentos de E/S USB.

**No incluir en GitHub** el ZIP de backup privado de C:, capturas de consola con rutas personales, seriales de disco, ni logs sin sanitizar. El JSON workflow que figura aquí **todavía no ha sido añadido al paquete**, por lo que su hash es una referencia para la futura exportación.
