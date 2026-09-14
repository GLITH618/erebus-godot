class_name ErebusConfig
extends RefCounted

const TILE := 16.0
const MAP_TILES := 240
const WORLD := 3840.0
const CENTER := 1920.0
const CRATER_R := 920.0
const PLAYER_SPEED := 64.0
const PLAYER_R := 7.0
const ZOOM_3D := 0.28
const ZOOM_3D_FULL := 0.14
const ZOOM_MIN := 0.07
const ZOOM_MAX := 2.2
const DAY_LEN := 420.0
const FOG_CELL := 48.0
const FOG_W := 80
const VISION_R := 220.0
const LAND_NEAR := 260.0
const CAP_ANGLE := 0.82
const ASTRONAUT_CELL := 64
const ITEM_CELL := 32
const ITEM_COLS := 4
const RESOURCE_CELL := 40

const ITEMS := {
	"pico": {"name": "Pico", "max": 1, "icon": 0, "usable": false},
	"regolito": {"name": "Regolito", "max": 99, "icon": 1, "usable": false},
	"hierro": {"name": "Hierro", "max": 99, "icon": 2, "usable": false},
	"caja": {"name": "Suministros", "max": 20, "icon": 3, "usable": false},
	"oxigeno": {"name": "Tanque O2", "max": 8, "icon": 4, "usable": true},
	"botiquin": {"name": "Botiquin", "max": 8, "icon": 5, "usable": true},
	"comida": {"name": "Racion", "max": 20, "icon": 6, "usable": true},
	"pieza": {"name": "Pieza antena", "max": 4, "icon": 7, "usable": false},
	"hielo": {"name": "Hielo", "max": 99, "icon": 8, "usable": false},
	"cobre": {"name": "Cobre", "max": 99, "icon": 9, "usable": false},
	"titanio": {"name": "Titanio", "max": 99, "icon": 10, "usable": false},
	"lingote": {"name": "Lingote", "max": 40, "icon": 11, "usable": false},
}

const ITEM_ORDER := [
	"pico", "regolito", "hierro", "hielo", "cobre", "titanio",
	"lingote", "caja", "oxigeno", "botiquin", "comida", "pieza",
]

const RESOURCE_META := {
	"regolith": {"label": "Regolito", "item": "regolito", "sprite": 0, "hp": 3, "mine_time": 0.85},
	"iron": {"label": "Hierro", "item": "hierro", "sprite": 1, "hp": 4, "mine_time": 1.15},
	"ice": {"label": "Hielo", "item": "hielo", "sprite": 2, "hp": 3, "mine_time": 1.0},
	"copper": {"label": "Cobre", "item": "cobre", "sprite": 3, "hp": 4, "mine_time": 1.2},
	"rare": {"label": "Titanio", "item": "titanio", "sprite": 4, "hp": 6, "mine_time": 1.55},
}

const RECIPES := [
	{"id": "o2", "name": "Tanque O2", "out": "oxigeno", "qty": 1, "station": "base", "need": {"hielo": 2, "regolito": 1}},
	{"id": "med", "name": "Botiquin", "out": "botiquin", "qty": 1, "station": "base", "need": {"titanio": 1, "caja": 1}},
	{"id": "food", "name": "Racion", "out": "comida", "qty": 2, "station": "base", "need": {"hielo": 2, "regolito": 1}},
	{"id": "crate", "name": "Suministros", "out": "caja", "qty": 1, "station": "", "need": {"regolito": 4, "hierro": 1}},
	{"id": "ingot", "name": "Lingote", "out": "lingote", "qty": 1, "station": "", "need": {"hierro": 2, "cobre": 1}},
	{"id": "part", "name": "Pieza antena", "out": "pieza", "qty": 1, "station": "base", "need": {"lingote": 2, "titanio": 1, "cobre": 1}},
]

const BUILDING_SCALE := {
	"habitat": 0.72,
	"greenhouse": 0.7,
	"solar": 0.62,
	"antenna": 0.7,
	"medbay": 0.7,
	"rover": 0.68,
	"crates": 0.7,
}

const BUILDING_RADIUS := {
	"habitat": 46.0,
	"greenhouse": 36.0,
	"solar": 28.0,
	"medbay": 30.0,
	"rover": 22.0,
	"crates": 18.0,
	"antenna": 26.0,
}

static func empty_inv() -> Dictionary:
	var inv := {}
	for id in ITEM_ORDER:
		inv[id] = 0
	return inv

static func icon_rect(index: int) -> Rect2:
	var col := index % ITEM_COLS
	var row := int(index / float(ITEM_COLS))
	return Rect2(col * ITEM_CELL, row * ITEM_CELL, ITEM_CELL, ITEM_CELL)

static func resource_rect(index: int) -> Rect2:
	var col := index % 3
	var row := int(index / 3.0)
	return Rect2(col * RESOURCE_CELL, row * RESOURCE_CELL, RESOURCE_CELL, RESOURCE_CELL)

static func crater_rect(index: int) -> Rect2:
	var col := index % 3
	var row := int(index / 3.0)
	return Rect2(col * 56, row * 56, 56, 56)
