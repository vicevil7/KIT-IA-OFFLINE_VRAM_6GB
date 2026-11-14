import argparse
import ctypes
import hashlib
import json
import os
import secrets
import shutil
import struct
import sys
import time
import uuid

from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError


API = "http://127.0.0.1:8188"

WIDGETS = {
    "UnetLoaderGGUF": ["unet_name"],
    "CLIPLoader": ["clip_name", "type", "device"],
    "VAELoader": ["vae_name"],
    "CLIPTextEncode": ["text"],
    "EmptySD3LatentImage": [
        "width", "height", "batch_size"
    ],
    "ModelSamplingAuraFlow": ["shift"],
    "KSampler": [
        "seed",
        None,
        "steps",
        "cfg",
        "sampler_name",
        "scheduler",
        "denoise"
    ],
    "VAEDecode": [],
    "SaveImage": ["filename_prefix"]
}


# ==========================================
# DESCARGAS REAL DE WINDOWS
# ==========================================

def obtener_descargas_windows():
    """
    Consulta FOLDERID_Downloads mediante
    SHGetKnownFolderPath de Windows.

    Respeta carpetas Descargas redirigidas.
    """

    if os.name != "nt":
        raise RuntimeError(
            "La deteccion de Descargas requiere Windows."
        )

    class GUID(ctypes.Structure):
        _fields_ = [
            ("Data1", ctypes.c_uint32),
            ("Data2", ctypes.c_uint16),
            ("Data3", ctypes.c_uint16),
            ("Data4", ctypes.c_ubyte * 8)
        ]

    identificador = GUID.from_buffer_copy(
        uuid.UUID(
            "374DE290-123F-4565-9164-39C4925E467B"
        ).bytes_le
    )

    shell32 = ctypes.WinDLL("shell32")
    ole32 = ctypes.WinDLL("ole32")

    funcion = shell32.SHGetKnownFolderPath

    funcion.argtypes = [
        ctypes.POINTER(GUID),
        ctypes.c_uint32,
        ctypes.c_void_p,
        ctypes.POINTER(ctypes.c_void_p)
    ]

    funcion.restype = ctypes.c_long

    liberar = ole32.CoTaskMemFree
    liberar.argtypes = [ctypes.c_void_p]
    liberar.restype = None

    resultado = ctypes.c_void_p()

    codigo = funcion(
        ctypes.byref(identificador),
        0,
        None,
        ctypes.byref(resultado)
    )

    if codigo != 0 or not resultado.value:
        raise RuntimeError(
            "No se pudo consultar la carpeta Descargas de Windows."
        )

    try:
        ruta = ctypes.wstring_at(resultado.value)
    finally:
        liberar(resultado)

    carpeta = Path(ruta)

    if not carpeta.is_dir():
        raise RuntimeError(
            f"La carpeta Descargas no existe: {carpeta}"
        )

    return carpeta


# ==========================================
# COMUNICACION COMFYUI
# ==========================================

def consultar(ruta):
    with urlopen(API + ruta, timeout=30) as respuesta:
        return json.load(respuesta)


def enviar(ruta, datos):
    peticion = Request(
        API + ruta,
        data=json.dumps(datos).encode("utf-8"),
        headers={
            "Content-Type": "application/json"
        },
        method="POST"
    )

    try:
        with urlopen(peticion, timeout=60) as respuesta:
            return json.load(respuesta)

    except HTTPError as error:
        detalle = error.read().decode(
            "utf-8",
            errors="replace"
        )

        raise RuntimeError(
            f"HTTP {error.code}: {detalle[:3000]}"
        )


# ==========================================
# PREPARACION DEL WORKFLOW
# ==========================================

def preparar_grafo(
    workflow,
    informacion,
    texto,
    ancho,
    alto,
    semilla
):
    nodos = workflow["nodes"]

    enlaces = {
        int(x[0]): x
        for x in workflow["links"]
    }

    if len(nodos) != 10 or len(enlaces) != 10:
        raise RuntimeError(
            "Estructura del workflow inesperada."
        )

    grafo = {}

    for nodo in nodos:
        tipo = nodo["type"]
        ident = str(nodo["id"])

        if tipo not in WIDGETS:
            raise RuntimeError(
                f"Tipo de nodo inesperado: {tipo}"
            )

        if tipo not in informacion:
            raise RuntimeError(
                f"Nodo no disponible en ComfyUI: {tipo}"
            )

        entradas = {}

        for entrada in nodo.get("inputs", []):
            enlace_id = entrada.get("link")

            if enlace_id is None:
                continue

            enlace = enlaces[int(enlace_id)]

            if str(enlace[3]) != ident:
                raise RuntimeError(
                    "Conexion inconsistente."
                )

            entradas[entrada["name"]] = [
                str(enlace[1]),
                int(enlace[2])
            ]

        widgets = nodo.get(
            "widgets_values", []
        )

        nombres = WIDGETS[tipo]

        if len(widgets) != len(nombres):
            raise RuntimeError(
                f"Widgets inesperados para {tipo}"
            )

        for nombre, valor in zip(
            nombres,
            widgets
        ):
            if nombre is not None:
                entradas[nombre] = valor

        if tipo == "CLIPTextEncode" and ident == "4":
            entradas["text"] = texto

        if tipo == "EmptySD3LatentImage":
            entradas["width"] = ancho
            entradas["height"] = alto
            entradas["batch_size"] = 1

        if tipo == "KSampler":
            entradas["seed"] = semilla

        obligatorias = informacion[tipo][
            "input"
        ].get("required", {})

        faltantes = set(obligatorias) - set(
            entradas
        )

        if faltantes:
            raise RuntimeError(
                f"{tipo}: faltan entradas {faltantes}"
            )

        grafo[ident] = {
            "class_type": tipo,
            "inputs": entradas
        }

    return grafo


# ==========================================
# SELECCION DESTINO
# ==========================================

def preparar_destino(args, prefijo):
    if args.salida and args.carpeta:
        raise RuntimeError(
            "Utiliza -Salida o -Carpeta, pero no ambas."
        )

    if args.salida:
        destino = Path(
            args.salida
        ).expanduser().resolve()

        if destino.suffix.lower() != ".png":
            raise RuntimeError(
                "El archivo de salida debe terminar en .png."
            )

        tipo = "ARCHIVO PERSONALIZADO"

    else:
        if args.carpeta:
            carpeta = Path(
                args.carpeta
            ).expanduser().resolve()

            tipo = "CARPETA PERSONALIZADA"

        else:
            carpeta = obtener_descargas_windows()
            tipo = "DESCARGAS DE WINDOWS"

        destino = carpeta / (
            prefijo + ".png"
        )

    if not destino.parent.is_dir():
        raise RuntimeError(
            f"No existe la carpeta: {destino.parent}"
        )

    if destino.exists():
        raise RuntimeError(
            "El archivo de destino ya existe. "
            "No se sobrescribe."
        )

    return destino, tipo


# ==========================================
# GENERACION
# ==========================================

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--workflow",
        required=True
    )

    parser.add_argument(
        "--portable",
        required=True
    )

    parser.add_argument(
        "--pruebas",
        required=True
    )

    parser.add_argument(
        "--prompt",
        required=True
    )

    parser.add_argument(
        "--ancho",
        type=int,
        default=1024
    )

    parser.add_argument(
        "--alto",
        type=int,
        default=576
    )

    parser.add_argument(
        "--semilla",
        type=int,
        default=-1
    )

    parser.add_argument(
        "--salida",
        default=""
    )

    parser.add_argument(
        "--carpeta",
        default=""
    )

    args = parser.parse_args()

    if not args.prompt.strip():
        raise RuntimeError(
            "La descripcion esta vacia."
        )

    if len(args.prompt) > 4096:
        raise RuntimeError(
            "Descripcion demasiado larga."
        )

    for dimension in (
        args.ancho,
        args.alto
    ):
        if (
            not 256 <= dimension <= 1024
            or dimension % 16 != 0
        ):
            raise RuntimeError(
                "Las dimensiones deben estar entre "
                "256 y 1024 y ser multiplo de 16."
            )

    if (
        args.semilla < -1
        or args.semilla > 2**63 - 1
    ):
        raise RuntimeError(
            "Semilla fuera de rango."
        )

    semilla = (
        secrets.randbits(32)
        if args.semilla == -1
        else args.semilla
    )

    workflow_path = Path(args.workflow)
    portable = Path(args.portable)

    contenido = workflow_path.read_bytes()

    sha = hashlib.sha256(
        contenido
    ).hexdigest().upper()

    esperado = (
        "6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C"
    )

    if sha != esperado:
        raise RuntimeError(
            "El workflow base ha cambiado "
            "respecto al verificado."
        )

    workflow = json.loads(
        contenido.decode("utf-8-sig")
    )

    prefijo = (
        "ZImageTurbo-"
        + time.strftime("%Y%m%d-%H%M%S")
        + "-"
        + uuid.uuid4().hex[:8]
    )

    # Validar destino antes de generar.
    destino, tipo_destino = preparar_destino(
        args,
        prefijo
    )

    informacion = consultar(
        "/object_info"
    )

    grafo = preparar_grafo(
        workflow,
        informacion,
        args.prompt,
        args.ancho,
        args.alto,
        semilla
    )

    guardar = [
        k for k, v in grafo.items()
        if v["class_type"] == "SaveImage"
    ]

    if len(guardar) != 1:
        raise RuntimeError(
            "Debe existir un unico nodo SaveImage."
        )

    save_id = guardar[0]

    grafo[save_id]["inputs"][
        "filename_prefix"
    ] = prefijo

    print(
        "===== GENERACION NATURAL Z-IMAGE =====",
        flush=True
    )

    print(
        "RESOLUCION:",
        args.ancho,
        "x",
        args.alto,
        flush=True
    )

    print(
        "SEMILLA:",
        semilla,
        flush=True
    )

    print(
        "PASOS: 8 / CFG: 1",
        flush=True
    )

    print(
        "TIPO DESTINO:",
        tipo_destino,
        flush=True
    )

    print(
        "CARPETA DESTINO:",
        destino.parent,
        flush=True
    )

    inicio = time.monotonic()

    respuesta = enviar(
        "/prompt",
        {
            "prompt": grafo,
            "client_id": str(uuid.uuid4())
        }
    )

    if respuesta.get("error"):
        raise RuntimeError(
            "ComfyUI rechazo el workflow: "
            + str(respuesta["error"])
        )

    prompt_id = respuesta.get(
        "prompt_id"
    )

    if not prompt_id:
        raise RuntimeError(
            "ComfyUI no devolvio identificador."
        )

    print(
        "PROMPT ID:",
        prompt_id,
        flush=True
    )

    print(
        "GENERACION INICIADA",
        flush=True
    )

    limite = time.monotonic() + 1800
    ultimo_aviso = 0
    historial = None
    fallos = 0

    while time.monotonic() < limite:
        time.sleep(3)

        transcurrido = (
            time.monotonic() - inicio
        )

        if (
            transcurrido - ultimo_aviso
        ) >= 30:
            print(
                "GENERANDO - SEGUNDOS:",
                round(transcurrido, 1),
                flush=True
            )

            ultimo_aviso = transcurrido

        try:
            datos = consultar(
                "/history/" + prompt_id
            )

            fallos = 0

        except Exception:
            fallos += 1

            if fallos >= 6:
                raise RuntimeError(
                    "La API dejo de responder."
                )

            continue

        if prompt_id in datos:
            historial = datos[prompt_id]
            break

    if historial is None:
        raise RuntimeError(
            "Generacion sin resultado "
            "dentro del limite."
        )

    estado = historial.get(
        "status", {}
    )

    if estado.get("status_str") == "error":
        raise RuntimeError(
            "Error del motor: "
            + json.dumps(
                estado.get("messages", []),
                ensure_ascii=False
            )[-4000:]
        )

    imagenes = historial.get(
        "outputs", {}
    ).get(
        save_id, {}
    ).get("images", [])

    if len(imagenes) != 1:
        raise RuntimeError(
            "Se esperaba una imagen. "
            f"Recibidas: {len(imagenes)}"
        )

    imagen = imagenes[0]

    if imagen.get("type") != "output":
        raise RuntimeError(
            "Tipo de salida inesperado."
        )

    raiz = (
        portable / "ComfyUI" / "output"
    ).resolve()

    origen = (
        raiz
        / imagen.get("subfolder", "")
        / imagen["filename"]
    ).resolve()

    if not origen.is_relative_to(raiz):
        raise RuntimeError(
            "Ruta de salida no permitida."
        )

    if not origen.is_file():
        raise RuntimeError(
            "No se encontro la imagen generada."
        )

    # Comprobar el archivo antes de copiarlo.
    with origen.open("rb") as archivo:
        cabecera = archivo.read(24)

    if (
        cabecera[:8]
        != b"\x89PNG\r\n\x1a\n"
    ):
        raise RuntimeError(
            "La imagen generada no es PNG."
        )

    ancho, alto = struct.unpack(
        ">II",
        cabecera[16:24]
    )

    if (
        ancho,
        alto
    ) != (
        args.ancho,
        args.alto
    ):
        raise RuntimeError(
            "Dimensiones diferentes de las solicitadas."
        )

    # Modo exclusivo: nunca sobrescribir.
    with origen.open("rb") as fuente:
        with destino.open("xb") as salida:
            shutil.copyfileobj(
                fuente,
                salida
            )

    sha_png = hashlib.sha256(
        destino.read_bytes()
    ).hexdigest().upper()

    print(
        "IMAGEN:",
        destino,
        flush=True
    )

    print(
        "DIMENSIONES:",
        ancho,
        "x",
        alto,
        flush=True
    )

    print(
        "BYTES:",
        destino.stat().st_size,
        flush=True
    )

    print(
        "SHA256:",
        sha_png,
        flush=True
    )

    print(
        "TIEMPO GENERACION SEGUNDOS:",
        round(
            time.monotonic() - inicio,
            2
        ),
        flush=True
    )

    print(
        "RESULTADO FINAL: CORRECTO",
        flush=True
    )


if __name__ == "__main__":
    try:
        main()

    except Exception as error:
        print(
            "RESULTADO FINAL: ERROR",
            type(error).__name__,
            str(error),
            flush=True
        )

        sys.exit(1)
