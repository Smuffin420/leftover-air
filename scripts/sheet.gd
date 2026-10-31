extends Node3D
class_name BubbleSheet

signal did_pop(kind: String, count: int)
signal did_miss

const TOOL_HAND := 0
const TOOL_PAIR := 1
const TOOL_HAMMER := 2
const TOOL_TWIST := 3
const TOOL_ROW := 4
const TOOL_LANE := 5
const TOOL_BRAYER := 6

const BUBBLE_FULL_SCENE := preload("res://assets/bubbles/bubble_new_full.glb")
const BUBBLE_HURT_SCENE := preload("res://assets/bubbles/bubble_new_hurt.glb")
const BUBBLE_POP_SCENE := preload("res://assets/bubbles/bubble_new_pop.glb")
# Bottom of each dome in model space. The dome points along Y.
const BUBBLE_PLANE: Array[float] = [-0.1913, 0.0175, 0.0096]
const BUBBLE_OVERLAP := 1.0

var active: bool = false
var cols: int = 0
var rows: int = 0
var far_count: int = 0
var finger_cd: float = 0.26
var knuckle_tier: int = 0
var twist_tier: int = 1
var row_tier: int = 1
var lane_tier: int = 1
var brayer_tier: int = 1
var tool: int = TOOL_HAND

var _full: Array[bool] = []
var _crinkle: PackedFloat32Array = PackedFloat32Array()
var _src_full: Mesh
var _src_hurt: Mesh
var _src_pop: Mesh
var _view_full: MultiMeshInstance3D
var _view_hurt: MultiMeshInstance3D
var _view_pop: MultiMeshInstance3D
var _bubbles_dirty: bool = false
var _cd: float = 0.0
var _was_down: bool = false
var _press_cell: Vector2i = Vector2i(-99, -99)
var _dragged: bool = false
var _rows_fired: Dictionary = {}
var _last_twist: Vector2i = Vector2i(-99, -99)
var _miss_cell: Vector2i = Vector2i(-99, -99)
var _twist_serial: int = 0
var _width: float = 1.7
var _height: float = 1.05
var _margin: float = 0.16
var _film_z: float = 0.028
var _bubble: Color = Color("8fd0ea")


func begin(next_cols: int, next_rows: int, far: int, cd: float, knuckle: int, twist: int, row_level: int, lane_level: int, brayer_level: int, which: int, bubble: Color, paper_color: Color) -> void:
	cols = next_cols
	rows = next_rows
	far_count = far
	finger_cd = cd
	knuckle_tier = maxi(knuckle, 0)
	twist_tier = maxi(twist, 1)
	row_tier = maxi(row_level, 1)
	lane_tier = maxi(lane_level, 1)
	brayer_tier = maxi(brayer_level, 1)
	tool = which
	active = true
	visible = true
	_cd = 0.0
	_was_down = false
	_dragged = false
	_rows_fired.clear()
	_last_twist = Vector2i(-99, -99)
	_miss_cell = Vector2i(-99, -99)
	_full.clear()
	_crinkle = PackedFloat32Array()
	_crinkle.resize(cols * rows)
	_bubble = bubble
	_clear_children()
	_view_full = null
	_view_hurt = null
	_view_pop = null
	_ensure_bubble_meshes()
	_build_film(paper_color)
	for row in rows:
		for col in cols:
			_full.append(true)
	_view_full = _make_bubble_view(_src_full)
	_view_hurt = _make_bubble_view(_src_hurt)
	_view_pop = _make_bubble_view(_src_pop)
	_bubbles_dirty = true
	_flush_bubbles()


func bubbles_left() -> int:
	var left := 0
	for bubble in _full:
		if bubble:
			left += 1
	return left


func end_counts() -> Vector2i:
	var missed := 0
	for bubble in _full:
		if bubble:
			missed += 1
	var popped: int = cols * rows - missed
	active = false
	visible = false
	_was_down = false
	_clear_children()
	_view_full = null
	_view_hurt = null
	_view_pop = null
	_full.clear()
	return Vector2i(popped, missed)


func aim(on_sheet: bool, local_point: Vector2, lmb: bool, delta: float) -> void:
	if not active:
		return
	if _cd > 0.0:
		_cd = maxf(0.0, _cd - delta)
	var just: bool = lmb and not _was_down
	var released: bool = not lmb and _was_down
	_was_down = lmb
	if not on_sheet:
		if just:
			did_miss.emit()
		if released:
			_rows_fired.clear()
			_dragged = false
			_miss_cell = Vector2i(-99, -99)
		return
	var cell: Vector2i = _cell_at(local_point)
	if cell.x < 0:
		return
	if just:
		_press_cell = cell
		_dragged = false
		_rows_fired.clear()
		if tool == TOOL_HAND or tool == TOOL_PAIR:
			_try_hand(cell)
		elif tool == TOOL_HAMMER:
			_hammer(cell)
		elif tool == TOOL_TWIST:
			_do_twist(cell)
	elif lmb and tool == TOOL_HAMMER and _cd <= 0.0:
		_hammer(cell)
	elif lmb and tool == TOOL_TWIST and _cd <= 0.0 and cell != _last_twist:
		_do_twist(cell)
	elif lmb and tool >= TOOL_ROW and (cell.y != _press_cell.y or absi(cell.x - _press_cell.x) >= 1):
		_dragged = true
		_fire_band(cell.y)
	elif released and tool >= TOOL_ROW and not _dragged:
		_pop_flat(_press_cell)
	if released:
		_miss_cell = Vector2i(-99, -99)
	_flush_bubbles()


func _try_hand(cell: Vector2i) -> void:
	var count := 0
	if _pop_if_full(cell):
		count += 1
	if tool == TOOL_PAIR:
		var mirror_col: int = cols - 1 - cell.x
		if mirror_col != cell.x and _pop_if_full(Vector2i(mirror_col, cell.y)):
			count += 1
	if count == 0:
		_whiff(cell)
		return
	_miss_cell = Vector2i(-99, -99)
	var scale: float = 2.6 if _is_far(cell.y) else 1.0
	_cd = finger_cd * scale
	did_pop.emit("pop", count)


func _pop_if_full(cell: Vector2i) -> bool:
	var index: int = _index(cell.x, cell.y)
	if index < 0 or not _full[index]:
		return false
	_pop_index(index, 0.34)
	return true


func hand_points(local_point: Vector2) -> Dictionary:
	var x: float = local_point.x
	var y: float = local_point.y
	return {
		"left": to_global(Vector3(-absf(x), y, 0.0)),
		"right": to_global(Vector3(absf(x), y, 0.0)),
	}


func _hammer(cell: Vector2i) -> void:
	var origin_col: int = mini(maxi(cell.x, 0), maxi(cols - 2, 0))
	var origin_row: int = mini(maxi(cell.y, 0), maxi(rows - 2, 0))
	var count := 0
	for dr in 2:
		for dc in 2:
			var col: int = origin_col + dc
			var row: int = origin_row + dr
			if _inside(col, row) and _pop_if_full(Vector2i(col, row)):
				count += 1
	if count == 0:
		_whiff(cell)
		return
	_miss_cell = Vector2i(-99, -99)
	_cd = finger_cd
	did_pop.emit("pop", count)


func _do_twist(cell: Vector2i) -> void:
	_last_twist = cell
	_twist_serial += 1
	var survive: float = clampf(0.82 - 0.12 * float(twist_tier), 0.2, 0.85)
	var popped_count := 0
	for row in range(cell.y - 1, cell.y + 2):
		for col in range(cell.x - 1, cell.x + 2):
			if not _inside(col, row):
				continue
			var index: int = _index(col, row)
			_crinkle[index] = 1.0
			var corner: bool = absi(row - cell.y) == 1 and absi(col - cell.x) == 1
			var do_pop: bool = true
			if corner:
				do_pop = _unit(_twist_serial * 17 + row * 13 + col * 7) > survive
			if do_pop and _full[index]:
				_full[index] = false
				popped_count += 1
			_paint(index)
	if popped_count > 0:
		_miss_cell = Vector2i(-99, -99)
		did_pop.emit("twist", popped_count)
	else:
		_whiff(cell)
	_cd = 0.22


func _fire_band(center_row: int) -> void:
	var band: int = 1
	if tool == TOOL_ROW:
		band = row_tier
	elif tool == TOOL_LANE:
		band = 1 + lane_tier
	else:
		band = 2 + brayer_tier
	var start: int = center_row - int(band / 2)
	var popped_count := 0
	for row in range(start, start + band):
		if row < 0 or row >= rows or _rows_fired.has(row):
			continue
		_rows_fired[row] = true
		for col in cols:
			var index: int = _index(col, row)
			if _full[index]:
				popped_count += 1
			_full[index] = false
			_crinkle[index] = 0.0
			_paint(index)
	if popped_count > 0:
		_miss_cell = Vector2i(-99, -99)
		did_pop.emit("sweep", popped_count)


func _pop_flat(cell: Vector2i) -> void:
	if not _inside(cell.x, cell.y):
		return
	var index: int = _index(cell.x, cell.y)
	if _full[index]:
		_full[index] = false
		_miss_cell = Vector2i(-99, -99)
		did_pop.emit("pop", 1)
	else:
		_whiff(cell)
	_crinkle[index] = 0.0
	_paint(index)


func _whiff(cell: Vector2i) -> void:
	if cell == _miss_cell:
		return
	_miss_cell = cell
	did_miss.emit()


func _pop_index(index: int, amount: float) -> void:
	if not _full[index]:
		return
	_full[index] = false
	var row: int = int(index / cols)
	var col: int = index % cols
	for dr in range(-1, 2):
		for dc in range(-1, 2):
			var rr: int = row + dr
			var cc: int = col + dc
			if not _inside(cc, rr):
				continue
			var neighbor: int = _index(cc, rr)
			if not _full[neighbor]:
				continue
			var scale: float = 0.45 if dr != 0 or dc != 0 else 1.0
			_crinkle[neighbor] = minf(1.0, _crinkle[neighbor] + amount * scale)
			_paint(neighbor)
	_paint(index)
	_paint(index)


func _paint(_index: int) -> void:
	_bubbles_dirty = true


func _make_bubble_view(mesh: Mesh) -> MultiMeshInstance3D:
	var view := MultiMeshInstance3D.new()
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = false
	multi.mesh = mesh
	view.multimesh = multi
	view.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	view.sorting_offset = 2.0
	view.material_override = _plastic(0.72)
	add_child(view)
	return view


func _ensure_bubble_meshes() -> void:
	if _src_full != null:
		return
	_src_full = _pull_mesh(BUBBLE_FULL_SCENE)
	_src_hurt = _pull_mesh(BUBBLE_HURT_SCENE)
	_src_pop = _pull_mesh(BUBBLE_POP_SCENE)


func _pull_mesh(scene: PackedScene) -> Mesh:
	var root: Node = scene.instantiate()
	var found: Mesh = _first_mesh(root)
	root.free()
	return found


func _first_mesh(node: Node) -> Mesh:
	if node is MeshInstance3D:
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		if mesh_node.mesh != null:
			return mesh_node.mesh
	for child in node.get_children():
		var found: Mesh = _first_mesh(child)
		if found != null:
			return found
	return null


func _plastic(alpha: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(_bubble.r, _bubble.g, _bubble.b, alpha)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.16
	mat.metallic = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _bubble_state(index: int) -> int:
	if not _full[index]:
		return 2
	if _crinkle[index] >= 0.12:
		return 1
	return 0


func _flush_bubbles() -> void:
	if not _bubbles_dirty or _view_full == null:
		return
	_bubbles_dirty = false
	var cw: float = _width / float(maxi(cols, 1))
	var ch: float = _height / float(maxi(rows, 1))
	var sx: float = cw / 1.974 * BUBBLE_OVERLAP
	var sz: float = ch / 1.974 * BUBBLE_OVERLAP
	var sy: float = sx
	var basis := Basis(Vector3.RIGHT, PI * 0.5)
	basis.x *= sx
	basis.y *= sy
	basis.z *= sz
	var sit: float = _film_z + 0.016
	_fill_bubble_view(_view_full, 0, basis, sy, sit)
	_fill_bubble_view(_view_hurt, 1, basis, sy, sit)
	_fill_bubble_view(_view_pop, 2, basis, sy, sit)


func _fill_bubble_view(view: MultiMeshInstance3D, state: int, basis: Basis, sy: float, sit: float) -> void:
	var lifts: Array[Transform3D] = []
	var lift: float = sit - sy * BUBBLE_PLANE[state]
	if state != 0:
		lift += 0.014
	for row in rows:
		for col in cols:
			var index: int = _index(col, row)
			if _bubble_state(index) != state:
				continue
			var spot: Vector3 = _center(col, row)
			lifts.append(Transform3D(basis, Vector3(spot.x, spot.y, lift)))
	var multi: MultiMesh = view.multimesh
	multi.instance_count = lifts.size()
	for i in lifts.size():
		multi.set_instance_transform(i, lifts[i])


func _build_film(_paper_color: Color) -> void:
	var span := Vector2(_width + _margin * 2.0, _height + _margin * 2.0)
	var film := MeshInstance3D.new()
	var film_mesh := BoxMesh.new()
	film_mesh.size = Vector3(span.x, span.y, 0.012)
	film.mesh = film_mesh
	film.position = Vector3(0, 0, _film_z)
	var sheet := _plastic(0.48)
	sheet.roughness = 0.28
	film.material_override = sheet
	film.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(film)


func _center(col: int, row: int) -> Vector3:
	var x: float = (float(col) + 0.5) / float(cols) * _width - _width * 0.5
	var y: float = (float(row) + 0.5) / float(rows) * _height - _height * 0.5
	return Vector3(x, y, 0)


func _cell_at(local_point: Vector2) -> Vector2i:
	var x: float = local_point.x + _width * 0.5
	var y: float = local_point.y + _height * 0.5
	var col: int = int(x / _width * float(cols))
	var row: int = int(y / _height * float(rows))
	if not _inside(col, row):
		return Vector2i(-1, -1)
	return Vector2i(col, row)


func _is_far(row: int) -> bool:
	return far_count > 0 and row >= rows - far_count


func _inside(col: int, row: int) -> bool:
	return col >= 0 and row >= 0 and col < cols and row < rows


func _index(col: int, row: int) -> int:
	return row * cols + col


func _unit(n: int) -> float:
	var x: float = sin(float(n) * 12.9898) * 43758.5453
	return x - floor(x)


func _clear_children() -> void:
	var old: Array = get_children()
	for child in old:
		remove_child(child)
		child.free()


func to_sheet_local(world_point: Vector3) -> Vector2:
	var local: Vector3 = to_local(world_point)
	return Vector2(local.x, local.y)


func contains_local(local_point: Vector2) -> bool:
	return absf(local_point.x) <= _width * 0.5 + _margin and absf(local_point.y) <= _height * 0.5 + _margin
