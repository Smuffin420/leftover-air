extends Control

var _back: Callable = Callable()
var _page: String = "Controls"
var _body: VBoxContainer
var _tab_buttons: Dictionary = {}
var _listen: String = ""
var _listen_btn: Button


static func build(on_back: Callable) -> Control:
	var menu = preload("res://scripts/settings_menu.gd").new()
	menu._back = on_back
	menu._compose()
	return menu


func _compose() -> void:
	var UI = preload("res://scripts/ui_build.gd")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.05, 0.04, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UI.panel_style())
	card.custom_minimum_size = Vector2(720, 0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)
	var title: Label = UI.label("Settings", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(tabs)
	for page_name in ["Controls", "Audio", "Video", "Gameplay"]:
		var tab := Button.new()
		tab.text = page_name
		tab.focus_mode = Control.FOCUS_NONE
		tab.custom_minimum_size = Vector2(150, 36)
		tab.add_theme_font_size_override("font_size", 16)
		tab.add_theme_color_override("font_color", UI.INK)
		tab.pressed.connect(_show_page.bind(page_name))
		tabs.add_child(tab)
		_tab_buttons[page_name] = tab

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 420)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	var reset := UI.button("Reset all", Color("3d4a44"), false)
	reset.custom_minimum_size = Vector2(200, 46)
	reset.pressed.connect(_reset_all)
	buttons.add_child(reset)
	var back := UI.button("Back", Color("3d4a44"), false)
	back.custom_minimum_size = Vector2(200, 46)
	back.pressed.connect(_leave)
	buttons.add_child(back)
	_show_page("Controls")


func _leave() -> void:
	_cancel_listen()
	if _back.is_valid():
		_back.call()


func _reset_all() -> void:
	_cancel_listen()
	Settings.reset()
	_show_page(_page)


func _show_page(page_name: String) -> void:
	_cancel_listen()
	_page = page_name
	_paint_tabs()
	_clear_body()
	if page_name == "Audio":
		_page_audio()
	elif page_name == "Video":
		_page_video()
	elif page_name == "Gameplay":
		_page_game()
	else:
		_page_controls()


func _paint_tabs() -> void:
	for key in _tab_buttons.keys():
		var tab: Button = _tab_buttons[key] as Button
		var on: bool = str(key) == _page
		tab.modulate = Color.WHITE if on else Color(1, 1, 1, 0.45)


func _clear_body() -> void:
	var kids: Array = _body.get_children()
	for child in kids:
		_body.remove_child(child)
		child.free()


func _page_controls() -> void:
	_header("Look")
	_slider("Look speed X", 0.0008, 0.006, 0.0001, Settings.sens_x, "x", func(v: float) -> void:
		Settings.sens_x = v
		Settings.commit()
	)
	_slider("Look speed Y", 0.0008, 0.006, 0.0001, Settings.sens_y, "x", func(v: float) -> void:
		Settings.sens_y = v
		Settings.commit()
	)
	_slider("Mouse smoothing", 0.0, 1.0, 0.01, Settings.mouse_smooth, "pct", func(v: float) -> void:
		Settings.mouse_smooth = v
		Settings.commit()
	)
	_check("Invert X", Settings.invert_x, func(on: bool) -> void:
		Settings.invert_x = on
		Settings.commit()
	)
	_check("Invert Y", Settings.invert_y, func(on: bool) -> void:
		Settings.invert_y = on
		Settings.commit()
	)
	_check("Raw mouse input", Settings.raw_mouse, func(on: bool) -> void:
		Settings.raw_mouse = on
		Settings.commit()
	)
	_choice("Pop button", PackedStringArray(["Left mouse", "Right mouse"]), Settings.pop_button, func(index: int) -> void:
		Settings.pop_button = index
		Settings.commit()
	)
	_choice("Sprint", PackedStringArray(["Hold", "Toggle"]), (1 if Settings.sprint_toggle else 0), func(index: int) -> void:
		Settings.sprint_toggle = index == 1
		Settings.commit()
	)
	_note("Sprint does nothing until you buy it. Toggle stays on until you press it again. Arrow keys still walk.")
	_header("Keys")
	_bind("forward", "Walk forward")
	_bind("back", "Walk back")
	_bind("left", "Strafe left")
	_bind("right", "Strafe right")
	_bind("sprint", "Sprint")
	_bind("use", "Use / roll up")
	_bind("throw", "Throw")
	_bind("cart", "Load / take cart")
	_bind("tool1", "Tool 1  Hand")
	_bind("tool2", "Tool 2  Hands")
	_bind("tool3", "Tool 3  Hammer")
	_bind("tool4", "Tool 4  Twist")
	_bind("tool5", "Tool 5  Row")
	_bind("tool6", "Tool 6  Lane")
	_bind("tool7", "Tool 7  Brayer")
	_note("Click a key, then press the new one. Esc cancels. Esc itself always pauses, so it cannot be moved. Two actions cannot share a key.")


func _page_audio() -> void:
	_header("Volume")
	_slider("Master", 0.0, 1.0, 0.01, Settings.master, "pct", func(v: float) -> void:
		Settings.master = v
		Settings.commit()
	)
	_slider("Pops and machines", 0.0, 1.0, 0.01, Settings.effects, "pct", func(v: float) -> void:
		Settings.effects = v
		Settings.commit()
	)
	_slider("Footsteps", 0.0, 1.0, 0.01, Settings.steps, "pct", func(v: float) -> void:
		Settings.steps = v
		Settings.commit()
	)
	_slider("Boss voice", 0.0, 1.0, 0.01, Settings.voice, "pct", func(v: float) -> void:
		Settings.voice = v
		Settings.commit()
	)
	_slider("Bonus buzzer", 0.0, 1.0, 0.01, Settings.alerts, "pct", func(v: float) -> void:
		Settings.alerts = v
		Settings.commit()
	)
	_check("Mute when the window is in the background", Settings.mute_unfocused, func(on: bool) -> void:
		Settings.mute_unfocused = on
		Settings.commit()
	)
	_note("Pops, the furnace, the roll clunk, and the paper are on the machine slider. The trombone is the boss. The buzzer is only the bonus.")


func _page_video() -> void:
	_header("Display")
	_choice("Window", PackedStringArray(["Windowed", "Borderless", "Exclusive fullscreen"]), Settings.window_mode, func(index: int) -> void:
		Settings.window_mode = index
		Settings.commit()
	)
	var res_labels := PackedStringArray()
	for i in Settings.RES_W.size():
		res_labels.append(Settings.resolution_label(i))
	_choice("Resolution", res_labels, Settings.resolution, func(index: int) -> void:
		Settings.resolution = index
		Settings.commit()
	)
	_note("Resolution is used while windowed. Borderless and exclusive fill the monitor.")
	_choice("VSync", PackedStringArray(["Off", "On", "Adaptive"]), Settings.vsync, func(index: int) -> void:
		Settings.vsync = index
		Settings.commit()
	)
	var fps_labels := PackedStringArray()
	for i in Settings.FPS.size():
		fps_labels.append(Settings.fps_label(i))
	_choice("Frame limit", fps_labels, Settings.fps_index(), func(index: int) -> void:
		Settings.fps_cap = Settings.FPS[index]
		Settings.commit()
	)
	_slider("Render scale", 0.5, 1.25, 0.05, Settings.render_scale, "pct", func(v: float) -> void:
		Settings.render_scale = v
		Settings.commit()
	)
	_choice("Antialiasing", PackedStringArray(["Off", "MSAA 2x", "MSAA 4x", "MSAA 8x"]), Settings.msaa_index(), func(index: int) -> void:
		var samples: Array[int] = [0, 2, 4, 8]
		Settings.msaa = samples[index]
		Settings.commit()
	)
	_check("FXAA", Settings.fxaa, func(on: bool) -> void:
		Settings.fxaa = on
		Settings.commit()
	)
	_header("Picture")
	_slider("Field of view", 60.0, 110.0, 1.0, Settings.fov, "deg", func(v: float) -> void:
		Settings.fov = v
		Settings.commit()
	)
	_slider("Brightness", 0.6, 1.6, 0.02, Settings.brightness, "pct", func(v: float) -> void:
		Settings.brightness = v
		Settings.commit()
	)
	_slider("Fog", 0.0, 2.0, 0.05, Settings.fog, "pct", func(v: float) -> void:
		Settings.fog = v
		Settings.commit()
	)
	_slider("Bloom", 0.0, 1.0, 0.02, Settings.bloom, "pct", func(v: float) -> void:
		Settings.bloom = v
		Settings.commit()
	)
	_choice("Shadows", PackedStringArray(["Off", "On", "High"]), Settings.shadows, func(index: int) -> void:
		Settings.shadows = index
		Settings.commit()
	)


func _page_game() -> void:
	_header("Comfort")
	_check("Reduce motion", Settings.reduce_motion, func(on: bool) -> void:
		Settings.reduce_motion = on
		Settings.commit()
	)
	_note("Reduce motion cuts the bench zoom short and turns view bob, hand bob, and shake off.")
	_slider("View bob", 0.0, 1.0, 0.01, Settings.view_bob, "pct", func(v: float) -> void:
		Settings.view_bob = v
		Settings.commit()
	)
	_slider("Hand bob", 0.0, 1.5, 0.01, Settings.hand_bob, "pct", func(v: float) -> void:
		Settings.hand_bob = v
		Settings.commit()
	)
	_slider("Camera shake", 0.0, 1.0, 0.01, Settings.shake, "pct", func(v: float) -> void:
		Settings.shake = v
		Settings.commit()
	)
	_slider("Bench zoom time", 0.2, 1.4, 0.05, Settings.zoom_seconds, "sec", func(v: float) -> void:
		Settings.zoom_seconds = v
		Settings.commit()
	)
	_slider("Bench zoom", 28.0, 60.0, 1.0, Settings.table_fov, "deg", func(v: float) -> void:
		Settings.table_fov = v
		Settings.commit()
	)
	_header("HUD")
	_slider("HUD size", 0.8, 1.6, 0.05, Settings.hud_scale, "pct", func(v: float) -> void:
		Settings.hud_scale = v
		Settings.commit()
	)
	_slider("Subtitle size", 0.8, 2.2, 0.05, Settings.subtitle_scale, "pct", func(v: float) -> void:
		Settings.subtitle_scale = v
		Settings.commit()
	)
	_slider("Subtitle hold", 0.6, 2.0, 0.05, Settings.subtitle_time, "pct", func(v: float) -> void:
		Settings.subtitle_time = v
		Settings.commit()
	)
	_slider("Crosshair size", 0.6, 2.2, 0.05, Settings.crosshair_scale, "pct", func(v: float) -> void:
		Settings.crosshair_scale = v
		Settings.commit()
	)
	_check("Crosshair", Settings.show_crosshair, func(on: bool) -> void:
		Settings.show_crosshair = on
		Settings.commit()
	)
	_check("Interaction prompts", Settings.show_prompts, func(on: bool) -> void:
		Settings.show_prompts = on
		Settings.commit()
	)
	_check("Money and rank", Settings.show_money, func(on: bool) -> void:
		Settings.show_money = on
		Settings.commit()
	)
	_check("Errand timer", Settings.show_timer, func(on: bool) -> void:
		Settings.show_timer = on
		Settings.commit()
	)
	_check("Timer turns red when you are late", Settings.late_flash, func(on: bool) -> void:
		Settings.late_flash = on
		Settings.commit()
	)
	_check("Tool name", Settings.show_tool, func(on: bool) -> void:
		Settings.show_tool = on
		Settings.commit()
	)
	_check("Bonus and promotion tracker", Settings.show_bonus, func(on: bool) -> void:
		Settings.show_bonus = on
		Settings.commit()
	)
	_check("Boss subtitles", Settings.show_subtitles, func(on: bool) -> void:
		Settings.show_subtitles = on
		Settings.commit()
	)
	_check("Burner receipt", Settings.show_receipts, func(on: bool) -> void:
		Settings.show_receipts = on
		Settings.commit()
	)
	_header("Lecture")
	var again: Button = preload("res://scripts/ui_build.gd").button("Replay the lecture", Color("3d4a44"), false)
	again.custom_minimum_size = Vector2(280, 46)
	again.pressed.connect(_replay_lecture)
	_body.add_child(again)
	_note("He starts the job speech over on your next roll. Your money stays where it is.")


func _replay_lecture() -> void:
	if not Game.has_save():
		return
	Game.tutorial = 0
	Game.save_shift()


func _header(text: String) -> void:
	var UI = preload("res://scripts/ui_build.gd")
	var lbl: Label = UI.label(text, 18)
	lbl.add_theme_color_override("font_color", UI.ACCENT)
	_body.add_child(lbl)


func _note(text: String) -> void:
	var UI = preload("res://scripts/ui_build.gd")
	var lbl: Label = UI.label(text, 13)
	lbl.add_theme_color_override("font_color", UI.DIM)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(lbl)


func _slider(title: String, min_v: float, max_v: float, step: float, value: float, kind: String, on_value: Callable) -> void:
	var UI = preload("res://scripts/ui_build.gd")
	var row := HBoxContainer.new()
	var name: Label = UI.label(title, 15)
	name.add_theme_color_override("font_color", UI.MUTED)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	var readout: Label = UI.label(_fmt(kind, value), 15)
	readout.custom_minimum_size = Vector2(78, 0)
	readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(readout)
	_body.add_child(row)
	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = value
	slider.custom_minimum_size = Vector2(0, 22)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(v: float) -> void:
		readout.text = _fmt(kind, v)
		on_value.call(v)
	)
	_body.add_child(slider)


func _fmt(kind: String, value: float) -> String:
	if kind == "x":
		return "%.2fx" % (value / 0.0022)
	if kind == "pct":
		return "%d%%" % int(round(value * 100.0))
	if kind == "deg":
		return "%d°" % int(round(value))
	if kind == "sec":
		return "%.2fs" % value
	return "%.2f" % value


func _check(title: String, pressed: bool, on_toggle: Callable) -> void:
	var UI = preload("res://scripts/ui_build.gd")
	var box := CheckButton.new()
	box.text = title
	box.focus_mode = Control.FOCUS_NONE
	box.button_pressed = pressed
	UI.mute(box)
	box.toggled.connect(on_toggle)
	_body.add_child(box)


func _choice(title: String, options: PackedStringArray, selected: int, on_pick: Callable) -> void:
	var UI = preload("res://scripts/ui_build.gd")
	var name: Label = UI.label(title, 15)
	name.add_theme_color_override("font_color", UI.MUTED)
	_body.add_child(name)
	var pick := OptionButton.new()
	pick.focus_mode = Control.FOCUS_NONE
	pick.custom_minimum_size = Vector2(0, 36)
	pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pick.add_theme_font_size_override("font_size", 16)
	pick.add_theme_color_override("font_color", UI.INK)
	for option in options:
		pick.add_item(option)
	pick.set_block_signals(true)
	pick.select(clampi(selected, 0, maxi(options.size() - 1, 0)))
	pick.set_block_signals(false)
	pick.item_selected.connect(on_pick)
	_body.add_child(pick)


func _bind(action: String, title: String) -> void:
	var UI = preload("res://scripts/ui_build.gd")
	var row := HBoxContainer.new()
	var name: Label = UI.label(title, 16)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(150, 36)
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", UI.INK)
	btn.text = Settings.key_label(Settings.bind_key(action))
	btn.pressed.connect(_arm.bind(action, btn))
	row.add_child(btn)
	_body.add_child(row)


func _arm(action: String, btn: Button) -> void:
	_cancel_listen()
	_listen = action
	_listen_btn = btn
	btn.text = "Press a key"


func _cancel_listen() -> void:
	if _listen_btn != null and is_instance_valid(_listen_btn) and _listen != "":
		_listen_btn.text = Settings.key_label(Settings.bind_key(_listen))
	_listen = ""
	_listen_btn = null


func _input(event: InputEvent) -> void:
	if _listen == "":
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	get_viewport().set_input_as_handled()
	if key_event.keycode == KEY_ESCAPE:
		_cancel_listen()
		return
	var action := _listen
	_listen = ""
	_listen_btn = null
	Settings.set_bind(action, key_event.keycode)
	_show_page(_page)
