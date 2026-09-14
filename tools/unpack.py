#!/usr/bin/env python3
"""Decode packed sprites (and optional gzipped scripts) into the Godot project."""
from __future__ import annotations

import base64
import gzip
import io
import tarfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
B64 = ROOT / "tools" / "b64"
SPRITES = ROOT / "assets" / "sprites"
SCRIPTS = ROOT / "scripts"


def _b64_text(text: str) -> bytes:
    return base64.b64decode("".join(text.split()).encode("ascii"))


def _blob(path: Path) -> bytes:
    return _b64_text(path.read_text())


def extract_tgz(data: bytes, dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
        try:
            tar.extractall(dest, filter="data")
        except TypeError:
            tar.extractall(dest)


def _write_png(name: str, data: bytes) -> None:
    out = SPRITES / name
    out.write_bytes(data)
    print(" ", out.relative_to(ROOT))


def main() -> None:
    SPRITES.mkdir(parents=True, exist_ok=True)
    SCRIPTS.mkdir(parents=True, exist_ok=True)
    B64.mkdir(parents=True, exist_ok=True)

    for p in sorted(B64.glob("*.png.b64")):
        _write_png(p.name[: -len(".b64")], _blob(p))

    # Split uploads: astronaut.png.b64.00 + .01 + ...
    groups: dict[str, list[Path]] = defaultdict(list)
    for p in sorted(B64.glob("*.png.b64.*")):
        groups[p.name.rsplit(".", 1)[0]].append(p)
    for group, files in groups.items():
        name = group[: -len(".b64")]
        data = _b64_text("".join(f.read_text() for f in files))
        _write_png(name, data)
        print(f"    ({len(files)} chunks)")

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
    return _b64_text("".join(p.read_text() for p in paths))


if __name__ == "__main__":
    main()
