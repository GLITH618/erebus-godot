#!/usr/bin/env python3
"""Decode packed sprites into assets/sprites/."""
from __future__ import annotations

import base64
import io
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
B64 = ROOT / "tools" / "b64"
SPRITES = ROOT / "assets" / "sprites"


def extract_tgz(data: bytes, dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
        try:
            tar.extractall(dest, filter="data")
        except TypeError:
            tar.extractall(dest)


def main() -> None:
    SPRITES.mkdir(parents=True, exist_ok=True)
    B64.mkdir(parents=True, exist_ok=True)
    n = 0
    for p in sorted(B64.glob("*.png.b64")):
        out = SPRITES / p.name[: -len(".b64")]
        blob = "".join(p.read_text().split())
        out.write_bytes(base64.b64decode(blob.encode("ascii")))
        print(" ", out.name)
        n += 1
    chunks = sorted(B64.glob("sprites.tgz.b64.*"))
    if chunks and n == 0:
        blob = "".join("".join(x.read_text().split()) for x in chunks)
        extract_tgz(base64.b64decode(blob.encode("ascii")), SPRITES)
        print("sprites archive extracted")
    print("Listo. Abre project.godot en Godot 4.3+")
    if not (SPRITES / "moon.png").exists():
        print("(moon.png opcional: la Luna 3D usa esfera gris si falta)")


if __name__ == "__main__":
    main()
