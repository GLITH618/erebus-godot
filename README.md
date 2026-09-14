# EREBUS — Godot 4

Supervivencia lunar en pixel art (cráter Erebus). Proyecto **Godot 4.3+**.

**Repo:** https://github.com/GLITH618/erebus-godot  
**Descargar ZIP:** https://github.com/GLITH618/erebus-godot/archive/refs/heads/main.zip

## Cómo jugar

```bash
git clone https://github.com/GLITH618/erebus-godot.git
cd erebus-godot
python3 tools/unpack.py
```

1. Instala [Godot 4.3+](https://godotengine.org/download).
2. Project Manager → **Import** → esta carpeta (`project.godot`).
3. F5.

`unpack.py` decodifica los sprites (`tools/b64/*.b64` → `assets/sprites/*.png`).

## Controles

| Tecla | Acción |
|---|---|
| WASD / flechas | Mover |
| E / clic | Minar / recoger / reparar |
| C | Crafteo |
| TAB | Inventario |
| 1–8 | Hotbar |
| F | Usar (O2, botiquín, ración) |
| H | Cámara al astronauta |
| Rueda | Zoom (aleja = Luna 3D) |
| Arrastrar | Girar la Luna |
| Esc | Pausa |

Al orbitar, el anillo dorado es el punto de aterrizaje. Si no ves al astronauta hay niebla de guerra.

## Recetas

| Resultado | Materiales | Dónde |
|---|---|---|
| Tanque O2 | 2 hielo + 1 regolito | Base |
| Botiquín | 1 titanio + 1 caja | Base |
| Ración ×2 | 2 hielo + 1 regolito | Base |
| Suministros | 4 regolito + 1 hierro | Anywhere |
| Lingote | 2 hierro + 1 cobre | Anywhere |
| Pieza antena | 2 lingotes + 1 titanio + 1 cobre | Base |

Misión: 4 piezas y reparar la antena al norte.

## Estructura

- `scripts/` motor GDScript (mundo, minado, crafteo, niebla, zoom 2D/3D)
- `scenes/main.tscn` escena de entrada
- `assets/sprites/` PNG (tras unpack)
- `origen-web/` código original web (TypeScript + Three.js)
