"""Comprobación estática reproducible. No arranca motores ni escribe en el kit.

Ejecutar desde la raíz del repositorio: python tests/validar_fuentes.py
"""
from __future__ import annotations
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_WORKFLOW = '6F850478FAC4D33EA633E65E1ECFBC6362FE4A691F9889045CC1744BE9EEE91C'
FILES = [
    'ia_musica.ps1','ia_voz.ps1','ia_kokoro.ps1','kokoro_generar.py',
    'ia_comfyui.ps1','ia_imagen.ps1','ia_imagen_generar.py',
    'ia_help_extensiones.ps1','ia_help_extensiones.json',
]
for name in FILES:
    path = ROOT/'scripts'/name
    assert path.is_file(), path
    source = path.read_text(encoding='utf-8-sig')
    assert 'F:\\KIT_IA_OFFLINE' not in source and 'F:/KIT_IA_OFFLINE' not in source, name
    if name.endswith('.py'):
        ast.parse(source, filename=str(path))
    if name.endswith('.json'):
        obj = json.loads(source)
        assert len(obj) == 18
workflow = ROOT/'config/ComfyUI-Z-Image-Turbo-workflow.json'
assert hashlib.sha256(workflow.read_bytes()).hexdigest().upper() == EXPECTED_WORKFLOW
obj = json.loads(workflow.read_text(encoding='utf-8-sig'))
assert len(obj['nodes']) == 10 and len(obj['links']) == 10
assert len({n['id'] for n in obj['nodes']}) == 10
print('VALIDACION ESTATICA: OK — 9 archivos, 1 workflow; sin ejecutar motores')
