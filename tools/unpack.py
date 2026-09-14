#!/usr/bin/env python3
"""Decode base64 sprite dumps into assets/sprites/*.png"""
from __future__ import annotations

import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "tools" / "b64"
DST = ROOT / "assets" / "sprites"


def main() -> None:
    DST.mkdir(parents=True, exist_ok=True)
    files = sorted(SRC.glob("*.b64"))
    if not files:
        print("No hay archivos en tools/b64")
        return
    for src in files:
        name = src.name[:-4]  # strip .b64
        out = DST / name
        out.write_bytes(base64.b64decode(src.read_text().encode("ascii")))
        print("ok", out.relative_to(ROOT), out.stat().st_size, "bytes")
    print("Listo. Abre project.godot en Godot 4.3+")


if __name__ == "__main__":
    main()
