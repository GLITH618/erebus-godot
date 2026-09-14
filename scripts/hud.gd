class_name ErebusHUD
extends CanvasLayer

signal craft_requested(recipe_id: String)
signal slot_picked(index: int)
signal zoom_requested(dir: int)
signal start_new
signal start_continue

var _stats: Label
var _prompt: Label
var _toast: Label
var _orbit: Label
var _title: Control
var _craft_box: VBoxContainer
var _inv_box: VBoxContainer
var _hotbar: HBoxContainer
var _items_tex: Texture2D
var _has_save := false

func _ready() -> void:
	layer = 20
	_items_tex = load("res://assets/sprites/items.png")
	_build()

func set_has_save(v: bool) -> void:
	_has_save = v
	if _title:
		_title.get_node("ContinueBtn").visible = v

func _build() -> void:
	_stats = _make_label(Vector2(16, 12), 14)
	add_child(_stats)

	_prompt = _make_label(Vector2(0, 0), 14)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_prompt.offset_bottom = -90
	_prompt.offset_top = -120
	_prompt.add_theme_color_override("font_color", Color(0.31, 0.76, 0.97))
	add_child(_prompt)

	_toast = _make_label(Vector2(0, 72), 16)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_toast.offset_top = 72
	_toast.offset_bottom = 100
	add_child(_toast)

	_orbit = _make_label(Vector2(0, 0), 13)
	_orbit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_orbit.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_orbit.offset_top = -48
	_orbit.offset_bottom = -20
	_orbit.add_theme_color_override("font_color", Color(0.31, 0.76, 0.97))
	add_child(_orbit)

	_hotbar = HBoxContainer.new()
	_hotbar.alignment = BoxContainer.ALIGNMENT_CENTER
	_hotbar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hotbar.offset_left = -220
	_hotbar.offset_right = 220
	_hotbar.offset_top = -70
	_hotbar.offset_bottom = -16
	add_child(_hotbar)
	for i in 8:
		var b := Button.new()
		b.custom_minimum_size = Vector2(48, 48)
		b.pressed.connect(_on_slot.bind(i))
		_hotbar.add_child(b)

	var zoom_col := VBoxContainer.new()
	zoom_col.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	zoom_col.offset_left = -56
	zoom_col.offset_right = -16
	zoom_col.offset_top = -40
	zoom_col.offset_bottom = 40
	var zplus := Button.new()
	zplus.text = "+"
	zplus.pressed.connect(func(): zoom_requested.emit(1))
	var zminus := Button.new()
	zminus.text = "-"
	zminus.pressed.connect(func(): zoom_requested.emit(-1))
	zoom_col.add_child(zplus)
	zoom_col.add_child(zminus)
	add_child(zoom_col)

	_craft_box = VBoxContainer.new()
	_craft_box.visible = false
	_craft_box.set_anchors_preset(Control.PRESET_CENTER)
	_craft_box.offset_left = -180
	_craft_box.offset_right = 180
	_craft_box.offset_top = -200
	_craft_box.offset_bottom = 200
	add_child(_craft_box)

	_inv_box = VBoxContainer.new()
	_inv_box.visible = false
	_inv_box.set_anchors_preset(Control.PRESET_CENTER)
	_inv_box.offset_left = -160
	_inv_box.offset_right = 160
	_inv_box.offset_top = -140
	_inv_box.offset_bottom = 140
	add_child(_inv_box)

	_build_title()

func _build_title() -> void:
	_title = Control.new()
	_title.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_title)
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	col.offset_left = -200
	col.offset_right = 200
	col.offset_top = -220
	col.offset_bottom = -40
	col.alignment = BoxContainer.ALIGNMENT_END
	_title.add_child(col)

	var t := Label.new()
	t.text = "EREBUS"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 48)
	col.add_child(t)
	var s := Label.new()
	s.text = "SUPERVIVENCIA LUNAR  ·  CRATER EREBUS"
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_theme_font_size_override("font_size", 12)
	s.add_theme_color_override("font_color", Color(0.31, 0.76, 0.97))
	col.add_child(s)

	var nb := Button.new()
	nb.text = "NUEVA EXPEDICION"
	nb.pressed.connect(func(): start_new.emit())
	col.add_child(nb)
	var cb := Button.new()
	cb.name = "ContinueBtn"
	cb.text = "CONTINUAR"
	cb.visible = false
	cb.pressed.connect(func(): start_continue.emit())
	col.add_child(cb)
	var help := Label.new()
	help.autowrap_mode = TextServer.AUTOWRAP_WORD
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.text = "WASD mover · E/clic minar · C craftear · TAB inventario · H astronauta · rueda zoom · arrastra la Luna"
	help.add_theme_font_size_override("font_size", 11)
	help.add_theme_color_override("font_color", Color(0.55, 0.6, 0.67))
	col.add_child(help)

func show_title(v: bool) -> void:
	_title.visible = v
	_hotbar.visible = not v
	_stats.visible = not v

func _on_slot(i: int) -> void:
	slot_picked.emit(i)

func _make_label(pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	return l

func refresh(g: Dictionary) -> void:
	if g.get("title", false):
		show_title(true)
		_prompt.text = ""
		_toast.text = ""
		_orbit.text = "ARRASTRA PARA GIRAR LA LUNA"
		return
	show_title(false)
	_stats.text = "SALUD %d%%\nOXIGENO %d%%\nHAMBRE %d%%\nTEMP %d C\nDIA %d  %s" % [
		int(g.health), int(g.oxygen), int(g.hunger), int(g.temp), int(g.day), g.clock
	]
	_prompt.text = str(g.get("prompt", ""))
	_toast.text = str(g.get("toast", ""))
	var mode: String = g.get("mode", "surface")
	if mode == "orbit":
		_orbit.text = "ORBITA — arrastra para girar · rueda para aterrizar donde miras"
	elif mode == "blend":
		_orbit.text = "CURVATURA — acerca para bajar al anillo dorado"
	elif not g.get("follow_player", true):
		_orbit.text = "NIEBLA DE GUERRA · H volver al astronauta"
	else:
		_orbit.text = ""

	var hot: Array = g.get("hotbar", [])
	for i in mini(8, hot.size()):
		var b: Button = _hotbar.get_child(i)
		var slot: Dictionary = hot[i]
		var id: String = str(slot.get("id", ""))
		var count: int = int(slot.get("count", 0))
		var name := ""
		if id != "" and ErebusConfig.ITEMS.has(id):
			name = ErebusConfig.ITEMS[id]["name"]
		b.text = "%d\n%s\n%s" % [i + 1, name, str(count) if count > 1 else ""]
		b.modulate = Color(1.2, 1.2, 1.2) if int(g.get("selected", 0)) == i else Color.WHITE

	_craft_box.visible = bool(g.get("craft_open", false))
	_inv_box.visible = bool(g.get("inventory_open", false))
	if _craft_box.visible:
		_fill_craft(g.get("recipes", []))
	if _inv_box.visible:
		_fill_inv(g.get("inv_list", []))

func _fill_craft(recipes: Array) -> void:
	for c in _craft_box.get_children():
		c.queue_free()
	var title := Label.new()
	title.text = "CRAFTEO  (C cierra)"
	_craft_box.add_child(title)
	for r in recipes:
		var rec: Dictionary = r
		var b := Button.new()
		var needs := []
		for n in rec.get("need", []):
			needs.append("%s %d/%d" % [n.id, n.have, n.need])
		b.text = "%s x%d   %s" % [rec.name, rec.qty, " · ".join(needs)]
		b.disabled = not rec.get("can", false)
		var rid: String = rec.id
		b.pressed.connect(func(): craft_requested.emit(rid))
		_craft_box.add_child(b)

func _fill_inv(list: Array) -> void:
	for c in _inv_box.get_children():
		c.queue_free()
	var title := Label.new()
	title.text = "INVENTARIO  (TAB cierra)"
	_inv_box.add_child(title)
	if list.is_empty():
		var e := Label.new()
		e.text = "Vacio. Mina minerales con el pico."
		_inv_box.add_child(e)
		return
	for it in list:
		var l := Label.new()
		var id: String = it.id
		var nm: String = ErebusConfig.ITEMS[id]["name"] if ErebusConfig.ITEMS.has(id) else id
		l.text = "%s  x%d" % [nm, it.count]
		_inv_box.add_child(l)
