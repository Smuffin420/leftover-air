extends Node

signal changed

const RES_W: Array[int] = [1280, 1366, 1600, 1920, 2560, 3440]
const RES_H: Array[int] = [720, 768, 900, 1080, 1440, 1440]
const FPS: Array[int] = [0, 30, 60, 75, 120, 144, 165, 240]
const ACTIONS: PackedStringArray = ["forward", "back", "left", "right", "sprint", "use", "throw", "cart", "tool1", "tool2", "tool3", "tool4", "tool5", "tool6", "tool7"]

var sens_x: float = 0.0022
var sens_y: float = 0.0022
var invert_x: bool = false
var invert_y: bool = false
var mouse_smooth: float = 0.0
var raw_mouse: bool = false
var pop_button: int = 0
var sprint_toggle: bool = false
var binds: Dictionary = {}

var master: float = 0.8
var effects: float = 1.0
var steps: float = 1.0
var voice: float = 1.0
var alerts: float = 1.0
var mute_unfocused: bool = false

var window_mode: int = 0
var resolution: int = 0
var vsync: int = 1
var fps_cap: int = 0
var render_scale: float = 1.0
var msaa: int = 0
var fxaa: bool = false
var shadows: int = 1
var fog: float = 1.0
var brightness: float = 1.0
var bloom: float = 0.0
var fov: float = 75.0

var view_bob: float = 0.0
var hand_bob: float = 1.0
var shake: float = 0.0
var reduce_motion: bool = false
var zoom_seconds: float = 0.75
var table_fov: float = 42.0
var show_crosshair: bool = true
var crosshair_scale: float = 1.0
var show_prompts: bool = true
var show_timer: bool = true
var show_money: bool = true
var show_tool: bool = true
var show_bonus: bool = true
var show_subtitles: bool = true
var subtitle_scale: float = 1.0
var subtitle_time: float = 1.0
var show_receipts: bool = true
var late_flash: bool = true
var hud_scale: float = 1.0


func _ready() -> void:
	binds = _fresh_binds()
	_load()
	commit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and mute_unfocused:
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		AudioServer.set_bus_mute(0, false)


func commit() -> void:
	sens_x = clampf(sens_x, 0.0008, 0.006)
	sens_y = clampf(sens_y, 0.0008, 0.006)
	mouse_smooth = clampf(mouse_smooth, 0.0, 1.0)
	pop_button = clampi(pop_button, 0, 1)
	master = clampf(master, 0.0, 1.0)
	effects = clampf(effects, 0.0, 1.0)
	steps = clampf(steps, 0.0, 1.0)
	voice = clampf(voice, 0.0, 1.0)
	alerts = clampf(alerts, 0.0, 1.0)
	window_mode = clampi(window_mode, 0, 2)
	resolution = clampi(resolution, 0, RES_W.size() - 1)
	vsync = clampi(vsync, 0, 2)
	if FPS.find(fps_cap) < 0:
		fps_cap = 0
	render_scale = clampf(render_scale, 0.5, 1.25)
	if msaa != 2 and msaa != 4 and msaa != 8:
		msaa = 0
	shadows = clampi(shadows, 0, 2)
	fog = clampf(fog, 0.0, 2.0)
	brightness = clampf(brightness, 0.6, 1.6)
	bloom = clampf(bloom, 0.0, 1.0)
	fov = clampf(fov, 60.0, 110.0)
	view_bob = clampf(view_bob, 0.0, 1.0)
	hand_bob = clampf(hand_bob, 0.0, 1.5)
	shake = clampf(shake, 0.0, 1.0)
	zoom_seconds = clampf(zoom_seconds, 0.2, 1.4)
	table_fov = clampf(table_fov, 28.0, 60.0)
	crosshair_scale = clampf(crosshair_scale, 0.6, 2.2)
	subtitle_scale = clampf(subtitle_scale, 0.8, 2.2)
	subtitle_time = clampf(subtitle_time, 0.6, 2.0)
	hud_scale = clampf(hud_scale, 0.8, 1.6)
	_save()
	_apply_runtime()
	changed.emit()


func reset() -> void:
	sens_x = 0.0022
	sens_y = 0.0022
	invert_x = false
	invert_y = false
	mouse_smooth = 0.0
	raw_mouse = false
	pop_button = 0
	sprint_toggle = false
	master = 0.8
	effects = 1.0
	steps = 1.0
	voice = 1.0
	alerts = 1.0
	mute_unfocused = false
	window_mode = 0
	resolution = 0
	vsync = 1
	fps_cap = 0
	render_scale = 1.0
	msaa = 0
	fxaa = false
	shadows = 1
	fog = 1.0
	brightness = 1.0
	bloom = 0.0
	fov = 75.0
	view_bob = 0.0
	hand_bob = 1.0
	shake = 0.0
	reduce_motion = false
	zoom_seconds = 0.75
	table_fov = 42.0
	show_crosshair = true
	crosshair_scale = 1.0
	show_prompts = true
	show_timer = true
	show_money = true
	show_tool = true
	show_bonus = true
	show_subtitles = true
	subtitle_scale = 1.0
	subtitle_time = 1.0
	show_receipts = true
	late_flash = true
	hud_scale = 1.0
	binds = _fresh_binds()
	commit()


func held(action: String) -> bool:
	if Input.is_key_pressed(bind_key(action) as Key):
		return true
	if action == "forward":
		return Input.is_key_pressed(KEY_UP)
	if action == "back":
		return Input.is_key_pressed(KEY_DOWN)
	if action == "left":
		return Input.is_key_pressed(KEY_LEFT)
	if action == "right":
		return Input.is_key_pressed(KEY_RIGHT)
	return false


func pressed(event: InputEvent, action: String) -> bool:
	if not (event is InputEventKey):
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	return key_event.keycode == bind_key(action)


func pop_held() -> bool:
	var button := MOUSE_BUTTON_LEFT if pop_button == 0 else MOUSE_BUTTON_RIGHT
	return Input.is_mouse_button_pressed(button)


func bind_key(action: String) -> int:
	return int(binds.get(action, 0))


func key_label(key: int) -> String:
	var text := OS.get_keycode_string(key as Key)
	if text == "":
		return "Unbound"
	return text


func set_bind(action: String, key: Key) -> void:
	var next := int(key)
	for other in ACTIONS:
		if other != action and int(binds.get(other, -1)) == next:
			binds[other] = bind_key(action)
	binds[action] = next
	commit()


func zoom_time() -> float:
	if reduce_motion:
		return 0.2
	return zoom_seconds


func shake_scale() -> float:
	if reduce_motion:
		return 0.0
	return shake


func view_bob_scale() -> float:
	if reduce_motion:
		return 0.0
	return view_bob


func hand_bob_scale() -> float:
	if reduce_motion:
		return 0.0
	return hand_bob


func fps_index() -> int:
	var found := FPS.find(fps_cap)
	if found < 0:
		return 0
	return found


func msaa_index() -> int:
	if msaa == 2:
		return 1
	if msaa == 4:
		return 2
	if msaa == 8:
		return 3
	return 0


func resolution_label(index: int) -> String:
	var i := clampi(index, 0, RES_W.size() - 1)
	return "%d x %d" % [RES_W[i], RES_H[i]]


func fps_label(index: int) -> String:
	var cap := FPS[clampi(index, 0, FPS.size() - 1)]
	if cap == 0:
		return "Uncapped"
	return "%d" % cap


func bus_for(kind: String) -> String:
	if kind == "step":
		return "Steps"
	if kind == "wah":
		return "Voice"
	if kind == "buzzer":
		return "Alerts"
	return "Effects"


func _fresh_binds() -> Dictionary:
	return {
		"forward": int(KEY_W),
		"back": int(KEY_S),
		"left": int(KEY_A),
		"right": int(KEY_D),
		"sprint": int(KEY_SHIFT),
		"use": int(KEY_E),
		"throw": int(KEY_F),
		"cart": int(KEY_C),
		"tool1": int(KEY_1),
		"tool2": int(KEY_2),
		"tool3": int(KEY_3),
		"tool4": int(KEY_4),
		"tool5": int(KEY_5),
		"tool6": int(KEY_6),
		"tool7": int(KEY_7),
	}


func _apply_runtime() -> void:
	_apply_audio()
	Input.use_accumulated_input = not raw_mouse
	if DisplayServer.get_name() == "headless":
		return
	_apply_video()


func _apply_audio() -> void:
	_ensure_bus("Effects")
	_ensure_bus("Steps")
	_ensure_bus("Voice")
	_ensure_bus("Alerts")
	_set_bus("Master", master)
	_set_bus("Effects", effects)
	_set_bus("Steps", steps)
	_set_bus("Voice", voice)
	_set_bus("Alerts", alerts)


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")


func _set_bus(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	var db := -80.0 if linear <= 0.001 else linear_to_db(linear)
	AudioServer.set_bus_volume_db(idx, db)


func _apply_video() -> void:
	var mode := DisplayServer.WINDOW_MODE_WINDOWED
	if window_mode == 1:
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	elif window_mode == 2:
		mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
	if window_mode == 0:
		var size := Vector2i(RES_W[resolution], RES_H[resolution])
		if DisplayServer.window_get_size() != size:
			DisplayServer.window_set_size(size)
			var screen := DisplayServer.window_get_current_screen()
			var screen_size := DisplayServer.screen_get_size(screen)
			DisplayServer.window_set_position((screen_size - size) / 2)
	var vsync_mode := DisplayServer.VSYNC_ENABLED
	if vsync == 0:
		vsync_mode = DisplayServer.VSYNC_DISABLED
	elif vsync == 2:
		vsync_mode = DisplayServer.VSYNC_ADAPTIVE
	DisplayServer.window_set_vsync_mode(vsync_mode)
	Engine.max_fps = fps_cap
	var vp := get_tree().root
	if msaa == 2:
		vp.msaa_3d = Viewport.MSAA_2X
	elif msaa == 4:
		vp.msaa_3d = Viewport.MSAA_4X
	elif msaa == 8:
		vp.msaa_3d = Viewport.MSAA_8X
	else:
		vp.msaa_3d = Viewport.MSAA_DISABLED
	if fxaa:
		vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	else:
		vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	vp.scaling_3d_scale = render_scale
	vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("s", "sens_x", sens_x)
	cfg.set_value("s", "sens_y", sens_y)
	cfg.set_value("s", "invert_x", invert_x)
	cfg.set_value("s", "invert_y", invert_y)
	cfg.set_value("s", "mouse_smooth", mouse_smooth)
	cfg.set_value("s", "raw_mouse", raw_mouse)
	cfg.set_value("s", "pop_button", pop_button)
	cfg.set_value("s", "sprint_toggle", sprint_toggle)
	cfg.set_value("s", "master", master)
	cfg.set_value("s", "effects", effects)
	cfg.set_value("s", "steps", steps)
	cfg.set_value("s", "voice", voice)
	cfg.set_value("s", "alerts", alerts)
	cfg.set_value("s", "mute_unfocused", mute_unfocused)
	cfg.set_value("s", "window_mode", window_mode)
	cfg.set_value("s", "resolution", resolution)
	cfg.set_value("s", "vsync", vsync)
	cfg.set_value("s", "fps_cap", fps_cap)
	cfg.set_value("s", "render_scale", render_scale)
	cfg.set_value("s", "msaa", msaa)
	cfg.set_value("s", "fxaa", fxaa)
	cfg.set_value("s", "shadows", shadows)
	cfg.set_value("s", "fog", fog)
	cfg.set_value("s", "brightness", brightness)
	cfg.set_value("s", "bloom", bloom)
	cfg.set_value("s", "fov", fov)
	cfg.set_value("s", "view_bob", view_bob)
	cfg.set_value("s", "hand_bob", hand_bob)
	cfg.set_value("s", "shake", shake)
	cfg.set_value("s", "reduce_motion", reduce_motion)
	cfg.set_value("s", "zoom_seconds", zoom_seconds)
	cfg.set_value("s", "table_fov", table_fov)
	cfg.set_value("s", "show_crosshair", show_crosshair)
	cfg.set_value("s", "crosshair_scale", crosshair_scale)
	cfg.set_value("s", "show_prompts", show_prompts)
	cfg.set_value("s", "show_timer", show_timer)
	cfg.set_value("s", "show_money", show_money)
	cfg.set_value("s", "show_tool", show_tool)
	cfg.set_value("s", "show_bonus", show_bonus)
	cfg.set_value("s", "show_subtitles", show_subtitles)
	cfg.set_value("s", "subtitle_scale", subtitle_scale)
	cfg.set_value("s", "subtitle_time", subtitle_time)
	cfg.set_value("s", "show_receipts", show_receipts)
	cfg.set_value("s", "late_flash", late_flash)
	cfg.set_value("s", "hud_scale", hud_scale)
	var bind_bits: PackedStringArray = []
	for action in ACTIONS:
		bind_bits.append("%s:%d" % [action, bind_key(action)])
	cfg.set_value("s", "binds", ",".join(bind_bits))
	cfg.save("user://settings.cfg")


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	sens_x = float(cfg.get_value("s", "sens_x", cfg.get_value("s", "sensitivity", sens_x)))
	sens_y = float(cfg.get_value("s", "sens_y", cfg.get_value("s", "sensitivity", sens_y)))
	invert_x = bool(cfg.get_value("s", "invert_x", invert_x))
	invert_y = bool(cfg.get_value("s", "invert_y", invert_y))
	mouse_smooth = float(cfg.get_value("s", "mouse_smooth", mouse_smooth))
	raw_mouse = bool(cfg.get_value("s", "raw_mouse", raw_mouse))
	pop_button = int(cfg.get_value("s", "pop_button", pop_button))
	sprint_toggle = bool(cfg.get_value("s", "sprint_toggle", sprint_toggle))
	master = float(cfg.get_value("s", "master", cfg.get_value("s", "volume", master)))
	effects = float(cfg.get_value("s", "effects", effects))
	steps = float(cfg.get_value("s", "steps", steps))
	voice = float(cfg.get_value("s", "voice", voice))
	alerts = float(cfg.get_value("s", "alerts", alerts))
	mute_unfocused = bool(cfg.get_value("s", "mute_unfocused", mute_unfocused))
	var fullscreen_fallback := 1 if bool(cfg.get_value("s", "fullscreen", false)) else 0
	window_mode = int(cfg.get_value("s", "window_mode", fullscreen_fallback))
	resolution = int(cfg.get_value("s", "resolution", resolution))
	vsync = int(cfg.get_value("s", "vsync", vsync))
	fps_cap = int(cfg.get_value("s", "fps_cap", fps_cap))
	render_scale = float(cfg.get_value("s", "render_scale", render_scale))
	msaa = int(cfg.get_value("s", "msaa", msaa))
	fxaa = bool(cfg.get_value("s", "fxaa", fxaa))
	shadows = int(cfg.get_value("s", "shadows", shadows))
	fog = float(cfg.get_value("s", "fog", fog))
	brightness = float(cfg.get_value("s", "brightness", brightness))
	bloom = float(cfg.get_value("s", "bloom", bloom))
	fov = float(cfg.get_value("s", "fov", fov))
	view_bob = float(cfg.get_value("s", "view_bob", view_bob))
	hand_bob = float(cfg.get_value("s", "hand_bob", hand_bob))
	shake = float(cfg.get_value("s", "shake", shake))
	reduce_motion = bool(cfg.get_value("s", "reduce_motion", reduce_motion))
	zoom_seconds = float(cfg.get_value("s", "zoom_seconds", zoom_seconds))
	table_fov = float(cfg.get_value("s", "table_fov", table_fov))
	show_crosshair = bool(cfg.get_value("s", "show_crosshair", show_crosshair))
	crosshair_scale = float(cfg.get_value("s", "crosshair_scale", crosshair_scale))
	show_prompts = bool(cfg.get_value("s", "show_prompts", show_prompts))
	show_timer = bool(cfg.get_value("s", "show_timer", show_timer))
	show_money = bool(cfg.get_value("s", "show_money", show_money))
	show_tool = bool(cfg.get_value("s", "show_tool", show_tool))
	show_bonus = bool(cfg.get_value("s", "show_bonus", show_bonus))
	show_subtitles = bool(cfg.get_value("s", "show_subtitles", show_subtitles))
	subtitle_scale = float(cfg.get_value("s", "subtitle_scale", subtitle_scale))
	subtitle_time = float(cfg.get_value("s", "subtitle_time", subtitle_time))
	show_receipts = bool(cfg.get_value("s", "show_receipts", show_receipts))
	late_flash = bool(cfg.get_value("s", "late_flash", late_flash))
	hud_scale = float(cfg.get_value("s", "hud_scale", hud_scale))
	var packed := str(cfg.get_value("s", "binds", ""))
	if packed != "":
		binds = _fresh_binds()
		for piece in packed.split(",", false):
			var bits: PackedStringArray = piece.split(":", false)
			if bits.size() == 2 and binds.has(bits[0]):
				binds[bits[0]] = int(bits[1])
