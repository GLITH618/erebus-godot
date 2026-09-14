# Sprites empaquetados

GitHub MCP no acepta PNG binarios sin corromperlos. Cada `*.png.b64` es el PNG en Base64.

```bash
python3 tools/unpack.py
```

Eso escribe `assets/sprites/*.png`. `moon.png` / `moon-bump.png` no van en el repo (pesan ~6 MB); el juego usa una esfera gris si faltan.
