extends RefCounted

const INK := Color("f4f1e8")
const MUTED := Color("b7c0b4")
const DIM := Color("8ea196")
const PANEL := Color("1b2622")
const ACCENT := Color("e25b2a")
const GOOD := Color("b6e7a3")
const BAD := Color("e07a6a")


static func style(color: Color, radius: int = 8, border: bool = false, pad: float = 12.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.content_margin_left = pad
	box.content_margin_right = pad
	box.content_margin_top = pad * 0.7
	box.content_margin_bottom = pad * 0.7
	if border:
		box.border_color = Color(1, 1, 1, 0.08)
		box.set_border_width_all(1)
	return box


static func panel_style() -> StyleBoxFlat:
	return style(PANEL, 16, true, 22.0)


static func button(text: String, color: Color, wide: bool = true) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(340, 50) if wide else Vector2(0, 42)
	btn.add_theme_font_size_override("font_size", 18)
	var edged: bool = color.get_luminance() < 0.35
	btn.add_theme_stylebox_override("normal", style(color, 10, edged, 12.0))
	btn.add_theme_stylebox_override("hover", style(color.lightened(0.08), 10, edged, 12.0))
	btn.add_theme_stylebox_override("pressed", style(color.darkened(0.08), 10, edged, 12.0))
	btn.add_theme_color_override("font_color", INK)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	return btn


static func label(text: String, size: int) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", INK)
	return lbl


static func outline(lbl: Label, amount: int = 5) -> void:
	lbl.add_theme_constant_override("outline_size", amount)
	lbl.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.04, 0.88))


static func mute(node: Control) -> void:
	node.add_theme_color_override("font_color", INK)
	node.add_theme_font_size_override("font_size", 18)
