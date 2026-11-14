import argparse
import hashlib
import math
import os
import time
import wave
from datetime import datetime
from pathlib import Path

import numpy as np
import soundfile as sf
from kokoro_onnx import Kokoro
from kokoro_onnx.tokenizer import Tokenizer


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--texto", required=True)
    parser.add_argument("--voz", required=True,
                        choices=("em_santa", "ef_dora", "em_alex"))
    parser.add_argument("--velocidad", type=float, default=1.0)
    parser.add_argument("--destino", required=True)
    args = parser.parse_args()

    if not args.texto.strip():
        raise ValueError("El texto esta vacio")

    if not math.isfinite(args.velocidad) or not 0.7 <= args.velocidad <= 1.3:
        raise ValueError("Velocidad fuera de rango")

    ruta_raiz = os.environ.get("KIT_IA_OFFLINE_ROOT", "").strip()
    if not ruta_raiz:
        raise RuntimeError("Define KIT_IA_OFFLINE_ROOT antes de iniciar Kokoro")
    base = Path(ruta_raiz).expanduser().resolve()
    carpeta_modelos = base / "01_MODELOS/VOZ/Kokoro-v1.0"

    modelo = carpeta_modelos / "kokoro-v1.0.onnx"
    voces = carpeta_modelos / "voices-v1.0.bin"
    destino = Path(args.destino)

    for archivo in (modelo, voces):
        if not archivo.is_file():
            raise FileNotFoundError(str(archivo))

    if not destino.is_dir():
        raise FileNotFoundError(str(destino))

    tokenizer = Tokenizer()
    fonemas = tokenizer.phonemize(args.texto, lang="es")

    if not fonemas:
        raise RuntimeError("No se generaron fonemas")

    inicio = time.perf_counter()
    kokoro = Kokoro(str(modelo), str(voces))

    if args.voz not in kokoro.get_voices():
        raise RuntimeError("La voz no esta disponible")

    muestras, frecuencia = kokoro.create(
        fonemas,
        voice=args.voz,
        speed=args.velocidad,
        is_phonemes=True
    )

    audio = np.asarray(muestras)

    if audio.ndim != 1 or audio.size == 0:
        raise RuntimeError("Audio vacio o formato inesperado")

    if not np.isfinite(audio).all():
        raise RuntimeError("Audio con valores no validos")

    amplitud = float(np.max(np.abs(audio)))

    if amplitud < 0.001:
        raise RuntimeError("Audio practicamente silencioso")

    marca = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    nombre = f"Kokoro-{args.voz}-{marca}.wav"

    archivo = destino / nombre
    temporal = destino / (nombre + ".partial.wav")

    if archivo.exists() or temporal.exists():
        raise FileExistsError("El archivo de salida ya existe")

    sf.write(
        str(temporal),
        audio,
        int(frecuencia),
        format="WAV",
        subtype="PCM_16"
    )

    with wave.open(str(temporal), "rb") as wav:
        hz = wav.getframerate()
        frames = wav.getnframes()
        canales = wav.getnchannels()
        ancho = wav.getsampwidth()

    if hz <= 0 or frames <= 0 or canales != 1 or ancho != 2:
        raise RuntimeError("WAV generado no valido")

    temporal.rename(archivo)

    sha = hashlib.sha256()
    with archivo.open("rb") as f:
        for bloque in iter(lambda: f.read(4 * 1024 * 1024), b""):
            sha.update(bloque)

    transcurrido = time.perf_counter() - inicio

    print("===== KOKORO TTS =====")
    print("VOZ:", args.voz)
    print("IDIOMA: es")
    print("VELOCIDAD:", args.velocidad)
    print("DURACION AUDIO:", round(frames / hz, 2), "segundos")
    print("TIEMPO GENERACION:", round(transcurrido, 2), "segundos")
    print("FRECUENCIA:", hz, "Hz")
    print("SHA256:", sha.hexdigest().upper())
    print("ARCHIVO:", archivo)
    print("RESULTADO: CORRECTO")


if __name__ == "__main__":
    main()
