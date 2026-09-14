# Sprites empaquetados

GitHub MCP no acepta PNG binarios grandes. Cada `*.png.b64` es el PNG en Base64.
Los sprites grandes van partidos: `astronaut.png.b64.00`, `.01`, …

```bash
python3 tools/unpack.py
```

Eso escribe `assets/sprites/*.png` y restaura `scripts/main.gd`.
`moon.png` / `moon-bump.png` no van en el repo (pesan ~6 MB); el juego usa una esfera gris si faltan.
