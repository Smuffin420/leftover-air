extends Control

const UI = preload("res://scripts/ui_build.gd")
const SettingsMenu = preload("res://scripts/settings_menu.gd")

var _menu: VBoxContainer
var _settings: Control
var _confirm: Control
var _confirm_text: Label
var _confirm_for: String = "shift"
var _name_panel: Control
var _name_edit: LineEdit
var _name_hint: Label
var _name_for: String = "shift"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var bg := ColorRect.new()
	bg.color = Color("121816")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_menu = VBoxContainer.new()
	_menu.add_theme_constant_override("separation", 12)
	_menu.custom_minimum_size = Vector2(520, 0)
	center.add_child(_menu)

	var title: Label = UI.label("Leftover Air", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu.add_child(title)
	var version_text: String = str(ProjectSettings.get_setting("application/config/version", ""))
	var version: Label = UI.label(version_text, 15)
	version.add_theme_color_override("font_color", UI.MUTED)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu.add_child(version)
	var body: Label = UI.label("Walk for a roll. Pop it flat. Walk it to the fire.\nThe boss keeps whatever you leave full. Breathing it is your hobby, not his.", 18)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu.add_child(body)
	var controls: Label = UI.label("WASD to walk. Mouse to look. E to use. Shift to sprint, once HR sells it to you. The red button on the back wall is the boss. The computer to his right has the mail. Esc if you need a moment.", 15)
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_theme_color_override("font_color", UI.MUTED)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu.add_child(controls)

	if Game.has_save() and not Game.completed:
		var cont: Button = UI.button("Continue shift", Color("e25b2a"))
		cont.pressed.connect(_play)
		_menu.add_child(cont)
	elif Game.has_save() and Game.completed:
		var done: Button = UI.button("The office", Color("e25b2a"))
		done.pressed.connect(_play)
		_menu.add_child(done)

	var fresh: Button = UI.button("New shift", Color("3d4a44"))
	fresh.pressed.connect(_ask_new)
	_menu.add_child(fresh)

	if Game.speedrun_active():
		var cont_run: Button = UI.button("Continue speedrun", Color("8a6230"))
		cont_run.pressed.connect(_play_speed)
		_menu.add_child(cont_run)
		var fresh_run: Button = UI.button("New speedrun", Color("3d4a44"))
		fresh_run.pressed.connect(_ask_speed)
		_menu.add_child(fresh_run)
	else:
		var run: Button = UI.button("Speedrun", Color("8a6230"))
		run.pressed.connect(_start_speed)
		_menu.add_child(run)
	if Game.speedrun_pb >= 0.0 or Game.speedrun_active():
		var best_text := "Best  --"
		if Game.speedrun_pb >= 0.0:
			best_text = "Best  %s" % Game.format_time(Game.speedrun_pb)
		if Game.speedrun_active():
			var clock := Game.speedrun_clock()
			if clock >= 0.0:
				best_text = "%s     %s" % [Game.format_time(clock), best_text]
		var best: Label = UI.label(best_text, 15)
		best.add_theme_color_override("font_color", UI.MUTED)
		best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_menu.add_child(best)
	var dev: Button = UI.button(_dev_label(), Color("6a3030"))
	dev.pressed.connect(func() -> void:
		Game.dev_mode = not Game.dev_mode
		dev.text = _dev_label()
	)
	_menu.add_child(dev)
	var settings_btn: Button = UI.button("Settings", Color("3d4a44"))
	settings_btn.pressed.connect(_open_settings)
	_menu.add_child(settings_btn)
	var quit: Button = UI.button("Quit", Color("3d4a44"))
	quit.pressed.connect(func() -> void: get_tree().quit())
	_menu.add_child(quit)

	_settings = SettingsMenu.build(_close_settings)
	_settings.hide()
	add_child(_settings)

	_confirm = _build_confirm()
	_confirm.hide()
	add_child(_confirm)
	_name_panel = _build_name()
	_name_panel.hide()
	add_child(_name_panel)


func _dev_label() -> String:
	if Game.dev_mode:
		return "Dev mode: on"
	return "Dev mode: off"


func _play() -> void:
	Game.continue_shift()
	get_tree().change_scene_to_file("res://scenes/factory.tscn")


func _play_speed() -> void:
	Game.continue_speedrun()
	get_tree().change_scene_to_file("res://scenes/factory.tscn")


func _start_speed() -> void:
	_open_name("speed")


func _ask_new() -> void:
	if Game.has_save():
		_confirm_for = "shift"
		_confirm_text.text = "Scrap this shift and start over?"
		_menu.hide()
		_confirm.show()
		return
	_open_name("shift")


func _open_name(which: String) -> void:
	_name_for = which
	_name_hint.text = "The tube prints whatever you type. Eighteen letters."
	_name_edit.text = ""
	_menu.hide()
	_confirm.hide()
	_name_panel.show()
	_name_edit.grab_focus.call_deferred()


func _clock_in() -> void:
	var who := _clean_name(_name_edit.text)
	if who == "":
		_name_hint.text = "The tag needs a name."
		return
	if _name_for == "speed":
		Game.new_speedrun()
	else:
		Game.new_shift()
	Game.worker_name = who
	Game.badge_rank = -1
	Game.save_shift()
	get_tree().change_scene_to_file("res://scenes/factory.tscn")


func _clean_name(raw: String) -> String:
	return Game.clean_name(raw)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _name_panel != null and _name_panel.visible:
		_name_panel.hide()
		_menu.show()
		get_viewport().set_input_as_handled()


func _ask_speed() -> void:
	_confirm_for = "speed"
	_confirm_text.text = "Scrap the timed run and start the clock over? Your best stays. The clock runs in the shop and stops while paused."
	_menu.hide()
	_confirm.show()


func _open_settings() -> void:
	_menu.hide()
	_settings.show()


func _close_settings() -> void:
	_settings.hide()
	_menu.show()


func _build_confirm() -> Control:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.05, 0.04, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UI.panel_style())
	card.custom_minimum_size = Vector2(440, 0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	var text: Label = UI.label("Scrap this shift and start over?", 22)
	_confirm_text = text
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(text)
	var yes: Button = UI.button("Start over", Color("e25b2a"))
	yes.pressed.connect(func() -> void:
		_open_name(_confirm_for)
	)
	box.add_child(yes)
	var no: Button = UI.button("Back", Color("3d4a44"))
	no.pressed.connect(func() -> void:
		_confirm.hide()
		_menu.show()
	)
	box.add_child(no)
	return dim


func _build_name() -> Control:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.05, 0.04, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UI.panel_style())
	card.custom_minimum_size = Vector2(440, 0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	var text: Label = UI.label("Name for the tag.", 28)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(text)
	_name_hint = UI.label("The tube prints whatever you type. Eighteen letters.", 16)
	_name_hint.add_theme_color_override("font_color", UI.MUTED)
	_name_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_name_hint)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Your name"
	_name_edit.max_length = 18
	_name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_edit.custom_minimum_size = Vector2(0, 48)
	_name_edit.add_theme_font_size_override("font_size", 22)
	_name_edit.add_theme_color_override("font_color", UI.INK)
	_name_edit.add_theme_color_override("font_placeholder_color", UI.DIM)
	_name_edit.add_theme_color_override("caret_color", UI.INK)
	var field := UI.style(Color("121816"), 8, true, 10.0)
	_name_edit.add_theme_stylebox_override("normal", field)
	_name_edit.add_theme_stylebox_override("focus", field)
	_name_edit.text_submitted.connect(func(_text: String) -> void: _clock_in())
	box.add_child(_name_edit)
	var yes: Button = UI.button("Clock in", Color("e25b2a"))
	yes.pressed.connect(_clock_in)
	box.add_child(yes)
	var no: Button = UI.button("Back", Color("3d4a44"))
	no.pressed.connect(func() -> void:
		_name_panel.hide()
		_menu.show()
	)
	box.add_child(no)
	return dim
