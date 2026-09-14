#!/usr/bin/env python3
"""Decode packed sprites (and optional gzipped scripts) into the Godot project."""
from __future__ import annotations

import base64
import gzip
import io
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
B64 = ROOT / "tools" / "b64"
SPRITES = ROOT / "assets" / "sprites"
SCRIPTS = ROOT / "scripts"


def _blob(path: Path) -> bytes:
    return base64.b64decode("".join(path.read_text().split()).encode("ascii"))


def extract_tgz(data: bytes, dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
        try:
            tar.extractall(dest, filter="data")
        except TypeError:
            tar.extractall(dest)


def main() -> None:
    SPRITES.mkdir(parents=True, exist_ok=True)
    SCRIPTS.mkdir(parents=True, exist_ok=True)
    B64.mkdir(parents=True, exist_ok=True)

    for p in sorted(B64.glob("*.png.b64")):
        out = SPRITES / p.name[: -len(".b64")]
        out.write_bytes(_blob(p))
        print(" ", out.relative_to(ROOT))

    for p in sorted(B64.glob("*.gd.gz.b64")):
        out = SCRIPTS / p.name.replace(".gz.b64", "")
        out.write_bytes(gzip.decompress(_blob(p)))
        print(" ", out.relative_to(ROOT))

    chunks = sorted(B64.glob("sprites.tgz.b64.*"))
    if chunks and not any(SPRITES.glob("*.png")):
        extract_tgz(_blob_join(chunks), SPRITES)
        print(" sprites archive extracted")

    print("Listo. Abre project.godot en Godot 4.3+")
    if not (SPRITES / "moon.png").exists():
        print("(moon.png opcional: la Luna 3D usa esfera gris si falta)")


def _blob_join(paths: list[Path]) -> bytes:
    return base64.b64decode("".join("".join(p.read_text().split()) for p in paths).encode("ascii"))


if __name__ == "__main__":
    main()
