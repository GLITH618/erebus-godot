class_name MoonOrbit
extends Node3D

const CAP_ANGLE := 0.82
const MOON_R := 1.0

var yaw := 0.38
var pitch := 0.2
var distance := 3.55

var _camera: Camera3D
var _moon: MeshInstance3D
var _look_mark: MeshInstance3D
var _player_mark: MeshInstance3D
var _sun: DirectionalLight3D

func _ready() -> void:
	_build()

func _build() -> void:
	_camera = Camera3D.new()
	_camera.fov = 36.0
	_camera.near = 0.05
	_camera.far = 220.0
	add_child(_camera)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.02, 0.024, 0.047)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.35, 0.4, 0.5)
	e.ambient_light_energy = 0.25
	env.environment = e
	add_child(env)

	var stars := GPUParticles3D.new()
	# Simple star field as MultiMesh-less point sprites via Omni... skip, use CSG
	_add_stars()

	var sphere := SphereMesh.new()
	sphere.radius = MOON_R
	sphere.height = MOON_R * 2.0
	sphere.radial_segments = 96
	sphere.rings = 64
	var mat := StandardMaterial3D.new()
	var albedo: Texture2D = load("res://assets/sprites/moon.png")
	var bump: Texture2D = load("res://assets/sprites/moon-bump.png")
	if albedo:
		mat.albedo_texture = albedo
	else:
		mat.albedo_color = Color(0.78, 0.76, 0.73)
	if bump:
		mat.normal_enabled = true
		mat.normal_texture = bump
		mat.normal_scale = 0.6
	mat.roughness = 1.0
	mat.metallic = 0.02
	_moon = MeshInstance3D.new()
	_moon.mesh = sphere
	_moon.material_override = mat
	add_child(_moon)

	_sun = DirectionalLight3D.new()
	_sun.light_color = Color(1.0, 0.95, 0.87)
	_sun.light_energy = 2.2
	_sun.shadow_enabled = true
	add_child(_sun)

	var fill := DirectionalLight3D.new()
	fill.light_color = Color(0.42, 0.55, 1.0)
	fill.light_energy = 0.28
	fill.rotation_degrees = Vector3(20, 140, 0)
	add_child(fill)

	_player_mark = _make_marker(Color(0.31, 0.76, 0.97), 0.018)
	_moon.add_child(_player_mark)
	_look_mark = _make_marker(Color(0.88, 0.63, 0.23), 0.028)
	_moon.add_child(_look_mark)

	var earth := MeshInstance3D.new()
	var em := SphereMesh.new()
	em.radius = 0.26
	em.height = 0.52
	var emat := StandardMaterial3D.new()
	emat.albedo_color = Color(0.12, 0.28, 0.55)
	emat.emission_enabled = true
	emat.emission = Color(0.05, 0.12, 0.3)
	emat.emission_energy_multiplier = 0.4
	earth.mesh = em
	earth.material_override = emat
	earth.position = Vector3(-3.8, 0.45, -6.4)
	add_child(earth)

	_update_camera()

func _make_marker(color: Color, r: float) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.4
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.mesh = s
	m.material_override = mat
	return m

func _add_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 400
	var sm := SphereMesh.new()
	sm.radius = 0.03
	sm.height = 0.06
	sm.radial_segments = 4
	sm.rings = 2
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.92, 1.0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = mat
	mm.mesh = sm
	for i in 400:
		var r := 28.0 + rng.randf() * 40.0
		var theta := rng.randf() * TAU
		var phi := acos(2.0 * rng.randf() - 1.0)
		var p := Vector3(
			r * sin(phi) * cos(theta),
			r * cos(phi),
			r * sin(phi) * sin(theta)
		)
		var t := Transform3D(Basis.IDENTITY, p)
		mm.set_instance_transform(i, t)
	var inst := MultiMeshInstance3D.new()
	inst.multimesh = mm
	add_child(inst)

func orbit(dx: float, dy: float) -> void:
	yaw -= dx * 0.005
	pitch = clampf(pitch - dy * 0.004, -0.18, 1.12)
	_update_camera()

func auto_rotate(dt: float) -> void:
	yaw += dt * 0.12
	_update_camera()

func set_distance_from_zoom(zoom: float) -> void:
	var t := clampf((0.32 - zoom) / 0.25, 0.0, 1.0)
	distance = lerpf(1.48, 4.35, t)
	_update_camera()

func set_sun(azimuth: float, elevation: float) -> void:
	var el := maxf(0.04, elevation)
	_sun.position = Vector3(
		cos(azimuth) * cos(el) * 8.0,
		sin(el) * 8.0,
		sin(azimuth) * cos(el) * 8.0
	)
	_sun.look_at(Vector3.ZERO)
	_sun.light_energy = 0.45 + el * 2.2

func look_world() -> Dictionary:
	var cp := cos(pitch)
	var x := sin(yaw) * cp
	var y := sin(pitch)
	var z := cos(yaw) * cp
	return cap_to_world(x, y, z)

func player_in_view(wx: float, wy: float) -> bool:
	var p := world_to_cap(wx, wy, 1.0)
	var cp := cos(pitch)
	var cx := sin(yaw) * cp
	var cy := sin(pitch)
	var cz := cos(yaw) * cp
	var d := p.dot(Vector3(cx, cy, cz))
	return p.z > 0.12 and d > 0.78

func place_player(wx: float, wy: float) -> void:
	var p := world_to_cap(wx, wy, 1.02)
	_player_mark.position = p
	_player_mark.visible = p.z > 0.12

func place_look(wx: float, wy: float) -> void:
	var p := world_to_cap(wx, wy, 1.035)
	_look_mark.position = p
	_look_mark.visible = p.z > 0.02

func _update_camera() -> void:
	var cp := cos(pitch)
	_camera.position = Vector3(
		sin(yaw) * cp * distance,
		sin(pitch) * distance,
		cos(yaw) * cp * distance
	)
	_camera.look_at(Vector3.ZERO)

static func world_to_cap(wx: float, wy: float, r: float) -> Vector3:
	var dx := (wx - ErebusConfig.CENTER) / ErebusConfig.CRATER_R
	var dy := (ErebusConfig.CENTER - wy) / ErebusConfig.CRATER_R
	var t := Vector2(dx, dy).length()
	var a := atan2(dy, dx)
	var ang := minf(1.05, t) * CAP_ANGLE
	var rad := sin(ang) * r
	var z := cos(ang) * r
	return Vector3(cos(a) * rad, sin(a) * rad, z)

static func cap_to_world(x: float, y: float, z: float) -> Dictionary:
	var a := atan2(y, x)
	var ang := atan2(Vector2(x, y).length(), z)
	var t := ang / CAP_ANGLE
	var far_side := z < 0.08
	var on_cap := z > 0.12 and t <= 1.08
	var clamped := minf(t, 1.08)
	var dx := clamped * cos(a)
	var dy := clamped * sin(a)
	return {
		"x": ErebusConfig.CENTER + dx * ErebusConfig.CRATER_R,
		"y": ErebusConfig.CENTER - dy * ErebusConfig.CRATER_R,
		"on_cap": on_cap,
		"far_side": far_side,
	}
