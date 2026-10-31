extends Node3D
class_name ViewHands

const HAND_SCENE := preload("res://assets/hands/hand.glb")
const HAND_SCALE := 0.062
# The new hand is one solid mesh. Palm thickness is the mesh's thin axis.
const PALM_DOWN := Basis(Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0))
const PALM_UP := Basis(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0))
var _tip: Array[Vector3] = []

const IDLE_POS: Array[Vector3] = [Vector3(0.34, -0.22, -0.38), Vector3(-0.36, -0.24, -0.40)]
const WORK_POS: Array[Vector3] = [Vector3(0.18, -0.04, -0.48), Vector3(-0.24, -0.08, -0.50)]
const CARRY_POS: Array[Vector3] = [Vector3(0.13, -0.2, -0.4), Vector3(-0.13, -0.2, -0.4)]

const FINGERS: PackedStringArray = ["index", "middle", "ring", "pinky"]

var _half_for_right: Dictionary = {}
var _half_for_left: Dictionary = {}
var _rest_mesh: Array[ArrayMesh] = []
var _point_mesh: Array[ArrayMesh] = []
var _wrist: Array[Node3D] = []
var _skels: Array[Skeleton3D] = []
var _bones: Array[Dictionary] = []
var _roll: MeshInstance3D
var _skin_mats: Array[StandardMaterial3D] = []
var _skin_tex: Array = []
var _skin_color: Array[Color] = []
var _working: bool = false
var _tool: int = 0
var _carry_mode: int = 0
var _press: float = 0.0
var _press_off: float = 0.0
var _table: bool = false
var _aim := Vector3.ZERO
var _aim_left := Vector3.ZERO
var _aim_ok: bool = false
var _paired: bool = false
var _bob: float = 0.0
var _time: float = 0.0
var _twist: float = 0.0
var _sway: float = 0.0
var _pos: Array[Vector3] = [Vector3(0.34, -0.22, -0.38), Vector3(-0.36, -0.24, -0.40)]
var _basis: Array[Basis] = [Basis.IDENTITY, Basis.IDENTITY]


func _ready() -> void:
	_build_hand(true)
	_build_hand(false)
	_basis[0] = _grip(14.0, -12.0)
	_basis[1] = _grip(-14.0, -12.0)


func bind_roll(roll: MeshInstance3D) -> void:
	_roll = roll


func set_carry(mode: int) -> void:
	_carry_mode = mode


func set_working(active: bool) -> void:
	_working = active


func set_tool(which: int) -> void:
	_tool = which


func set_table(active: bool) -> void:
	_table = active
	if not active:
		for wrist in _wrist:
			wrist.scale = Vector3.ONE


func aim_table(point: Vector3) -> void:
	_aim = point
	_paired = false
	_aim_ok = true


func aim_pair(right_point: Vector3, left_point: Vector3) -> void:
	_aim = right_point
	_aim_left = left_point
	_paired = true
	_aim_ok = true


func _process(delta: float) -> void:
	_time += delta
	var body := get_parent().get_parent() as CharacterBody3D
	var moving: float = 0.0
	if body != null:
		moving = Vector2(body.velocity.x, body.velocity.z).length()
	_bob += delta * maxf(moving * 2.4, 0.7)
	var want_press: float = 0.0
	var clicking: bool = Settings.pop_held()
	if _table and clicking:
		want_press = 1.0
	elif _working and _tool == 0 and clicking:
		want_press = 1.0
	_press = move_toward(_press, want_press, delta * 22.0)
	if _wrist.size() > 1:
		_wrist[1].visible = not _table or _tool == 1
	var want_off: float = 1.0 if _table and _tool == 0 and clicking else 0.0
	_press_off = move_toward(_press_off, want_off, delta * 22.0)
	if _working and _tool == 3 and Settings.pop_held():
		_twist = sin(_time * 9.0) * 22.0
	else:
		_twist = move_toward(_twist, 0.0, delta * 90.0)
	if _working and _tool >= 4:
		var mv: Vector2 = Input.get_last_mouse_velocity()
		_sway += clampf(-mv.x * 0.012, -1.4, 1.4)
		_sway = clampf(_sway, -18.0, 18.0)
	_sway = lerpf(_sway, 0.0, 1.0 - exp(-4.0 * delta))
	if _table:
		_pose_table()
		return
	for i in 2:
		_pose_hand(i, delta)
	if _roll != null and _carry_mode != 0:
		var hold: Vector3 = _wrist[0].position + Vector3(0.0, 0.05, -0.02)
		if _wrist.size() > 1 and _wrist[1].visible:
			hold = (_wrist[0].position + _wrist[1].position) * 0.5 + Vector3(0.0, 0.055, 0.0)
		_roll.position = hold
		_roll.rotation_degrees = Vector3(0, 0, 90)


func _pose_hand(i: int, delta: float) -> void:
	var pos: Vector3 = IDLE_POS[i]
	var yaw: float = 14.0 if i == 0 else -14.0
	var pitch: float = -12.0
	var palms_up := false
	if _working:
		pos = WORK_POS[i]
		pitch = -32.0
	elif _carry_mode != 0:
		pos = CARRY_POS[i]
		pitch = 18.0
		yaw = 24.0 if i == 0 else -24.0
		palms_up = true
	var blend: float = 1.0 - exp(-9.0 * delta)
	_pos[i] = _pos[i].lerp(pos, blend)
	var want: Basis = _grip_up(yaw, pitch) if palms_up else _grip(yaw, pitch)
	var bob_mul: float = Settings.hand_bob_scale()
	var speed: float = _walk_speed()
	var swing: float = clampf(speed / 3.2, 0.0, 1.35) * bob_mul
	var phase: float = _bob
	if _carry_mode == 0:
		phase += PI if i == 1 else 0.0
	var stride: float = sin(phase)
	var swing_pitch: float = stride * 18.0 * swing
	var breathe_y: float = 0.0
	if _carry_mode != 0:
		swing_pitch *= 0.35
		var cup: float = -14.0 if i == 0 else 14.0
		want = want * Basis(Vector3.FORWARD, deg_to_rad(cup + stride * 4.0 * swing))
		want = want.rotated(Vector3.RIGHT, deg_to_rad(swing_pitch))
	else:
		if not _working:
			var inward: float = 75.0 if i == 0 else -75.0
			want = want * Basis(Vector3.UP, deg_to_rad(inward))
		want = want.rotated(Vector3.RIGHT, deg_to_rad(swing_pitch))
		var idle: float = (1.0 - clampf(swing, 0.0, 1.0)) * bob_mul
		breathe_y = sin(_time * 1.35 + float(i) * 0.7) * 0.012 * idle
		want = want.rotated(Vector3.UP, deg_to_rad(sin(_time * 0.85 + float(i)) * 6.0 * idle))
	_basis[i] = _basis[i].slerp(want, blend)
	var along: float = stride * 0.06 * swing
	var drop: float = (1.0 - absf(stride)) * 0.018 * swing
	if _carry_mode != 0:
		along *= 0.28
		drop *= 0.4
	var side: float = 0.0
	if _carry_mode == 0:
		side = stride * 0.016 * swing * (1.0 if i == 0 else -1.0)
	var push := Vector3.ZERO
	if _working and _tool == 0 and i == 0:
		push = Vector3(0.0, -0.012, -0.02) * _press
	var squeeze: float = 1.0
	if i == 0:
		squeeze = 1.0 - 0.05 * _press
	_wrist[i].scale = Vector3(squeeze, squeeze, 1.0)
	_wrist[i].position = _pos[i] + Vector3(side, -drop + breathe_y, -along) + push
	var basis: Basis = _basis[i]
	if i == 0:
		basis = basis * Basis(Vector3.UP, deg_to_rad(_sway)) * Basis(Vector3.FORWARD, deg_to_rad(_twist))
	_wrist[i].basis = basis
	_apply_shape(i, false)
	_curl_fingers(i)


func _pose_table() -> void:
	if not _aim_ok or _wrist.is_empty():
		return
	var spin: float = _twist if _tool == 3 else 0.0
	var count: int = 2 if _tool == 1 and _paired and _wrist.size() > 1 else 1
	for i in count:
		var poke: float = _press if i == 0 else _press_off
		var yaw: float = spin
		if _tool == 1:
			yaw += 8.0 if i == 0 else -8.0
		var poke_scale: float = 1.45 - 0.08 * poke
		_wrist[i].scale = Vector3(poke_scale, poke_scale, poke_scale)
		_wrist[i].global_basis = _grip(yaw, -6.0 - 28.0 * poke)
		_apply_shape(i, true)
		_curl_fingers(i)
		var spot: Vector3 = _aim if i == 0 else _aim_left
		_plant(i, spot + Vector3(0, 0.16 - 0.05 * poke, 0))


func _curl_fingers(i: int) -> void:
	# This hand has no skin weights, so the wrist pose carries the motion.
	if i >= _skels.size() or _skels[i] == null:
		return
	var amount: float = 0.28
	if _table:
		amount = 0.86
	elif _carry_mode != 0:
		amount = 0.72
	elif i == 0:
		amount = 0.46 + _press * 0.75
	else:
		amount = 0.46 + _press_off * 0.6
	amount += sin(_time * 1.5 + float(i)) * 0.025
	var poke: float = 0.02 + (_press if i == 0 else _press_off) * 0.08
	var skel: Skeleton3D = _skels[i]
	var bend: Array[float] = [0.45, 0.85, 0.65]
	for finger in FINGERS:
		var use: float = poke if _table and finger == "index" else amount
		for joint in 3:
			var bone: int = int(_bones[i]["%s_%d" % [finger, joint]])
			if bone < 0:
				continue
			var curl: float = use if _table and finger == "index" else use * bend[joint]
			skel.set_bone_pose_rotation(bone, Quaternion(Vector3.RIGHT, -curl))
	var thumb_amount: float = 0.18 if _table else amount
	var thumb_bend: Array[float] = [0.35, 0.6, 0.45]
	for joint in 3:
		var thumb: int = int(_bones[i]["thumb_%d" % joint])
		if thumb < 0:
			continue
		skel.set_bone_pose_rotation(thumb, Quaternion(Vector3.FORWARD, thumb_amount * thumb_bend[joint]))


func _grip(yaw_deg: float, pitch_deg: float) -> Basis:
	var pitched: Basis = PALM_DOWN.rotated(Vector3.RIGHT, deg_to_rad(pitch_deg))
	return pitched.rotated(Vector3.UP, deg_to_rad(yaw_deg))


func _grip_up(yaw_deg: float, pitch_deg: float) -> Basis:
	var pitched: Basis = PALM_UP.rotated(Vector3.RIGHT, deg_to_rad(pitch_deg))
	return pitched.rotated(Vector3.UP, deg_to_rad(yaw_deg))


func _plant(i: int, target: Vector3) -> void:
	var tip: Vector3 = _finger_tip(i)
	_wrist[i].global_position += target - tip


func _finger_tip(i: int) -> Vector3:
	var tip: Vector3 = _tip[i] if i < _tip.size() else Vector3(0, 0.12, 0)
	return _wrist[i].global_transform * tip


func _walk_speed() -> float:
	var body := get_parent().get_parent() as CharacterBody3D
	if body == null:
		return 0.0
	return Vector2(body.velocity.x, body.velocity.z).length()


func _bob_amp() -> float:
	var body := get_parent().get_parent() as CharacterBody3D
	if body == null:
		return 0.0
	return Vector2(body.velocity.x, body.velocity.z).length() * 0.004


func _build_hand(right: bool) -> void:
	_ensure_halves()
	var wrist := Node3D.new()
	wrist.name = "RightHand" if right else "LeftHand"
	add_child(wrist)
	var half: Dictionary = _half_for_right if right else _half_for_left
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = "Hand"
	var rest_mesh: ArrayMesh = half["rest"]
	mesh_node.mesh = rest_mesh
	wrist.add_child(mesh_node)
	_soften(mesh_node)
	_rest_mesh.append(rest_mesh)
	_point_mesh.append(half["point"])
	_tip.append(_seat_mesh(mesh_node, half["tip"]))
	_wrist.append(wrist)
	_skels.append(null)
	_bones.append({})


func _apply_shape(i: int, pointing: bool) -> void:
	if i >= _wrist.size() or _wrist[i].get_child_count() == 0:
		return
	var mesh_node: MeshInstance3D = _wrist[i].get_child(0) as MeshInstance3D
	var want: ArrayMesh = _point_mesh[i] if pointing else _rest_mesh[i]
	if mesh_node.mesh != want:
		mesh_node.mesh = want


func _ensure_halves() -> void:
	if not _half_for_right.is_empty():
		return
	var model: Node3D = HAND_SCENE.instantiate()
	var mesh_node: MeshInstance3D = _find_mesh(model)
	var source: ArrayMesh = mesh_node.mesh as ArrayMesh
	var baked: Transform3D = _chain(model, mesh_node)
	var arrays: Array = source.surface_get_arrays(0)
	var skin: Material = source.surface_get_material(0)
	# The file's +X hand has its thumb toward the center. Worn on the left wrist, that thumb points inward.
	_half_for_left = _make_half(model, arrays, baked, true, skin)
	_half_for_right = _make_half(model, arrays, baked, false, skin)
	model.free()


func _make_half(model: Node3D, arrays: Array, baked: Transform3D, positive: bool, skin: Material) -> Dictionary:
	var skel: Skeleton3D = _skeleton_on(model, positive)
	var skel_xform: Transform3D = _chain(model, skel)
	var names: PackedStringArray = PackedStringArray()
	var parents := PackedInt32Array()
	var rests: Array[Transform3D] = []
	for b in skel.get_bone_count():
		names.append(skel.get_bone_name(b))
		parents.append(skel.get_bone_parent(b))
		rests.append(skel_xform * skel.get_bone_global_rest(b))
	var sign: float = _curl_sign(rests, parents, names)
	var split: Dictionary = _half_mesh(arrays, baked, positive, skin)
	var verts: PackedVector3Array = split["verts"]
	var bind: PackedInt32Array = _bind_verts(verts, rests, parents, names)
	var tip: Vector3 = _index_tip(verts, bind, names)
	var pointed: ArrayMesh = _deform_mesh(split["mesh"], verts, split["normals"], bind, rests, parents, names, sign, skin)
	return {"rest": split["mesh"], "point": pointed, "tip": tip}


func _half_mesh(arrays: Array, baked: Transform3D, right: bool, skin: Material) -> Dictionary:
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var has_normals: bool = normals.size() == verts.size()
	var remap := PackedInt32Array()
	remap.resize(verts.size())
	remap.fill(-1)
	var out_v := PackedVector3Array()
	var out_n := PackedVector3Array()
	var out_i := PackedInt32Array()
	for t in range(0, indices.size(), 3):
		var a: int = indices[t]
		var b: int = indices[t + 1]
		var c: int = indices[t + 2]
		var mid_x: float = (verts[a].x + verts[b].x + verts[c].x) / 3.0
		if right != (mid_x > 0.0):
			continue
		out_i.append(_take_vert(a, verts, normals, has_normals, baked, remap, out_v, out_n))
		out_i.append(_take_vert(b, verts, normals, has_normals, baked, remap, out_v, out_n))
		out_i.append(_take_vert(c, verts, normals, has_normals, baked, remap, out_v, out_n))
	var mesh := ArrayMesh.new()
	var built: Array = []
	built.resize(Mesh.ARRAY_MAX)
	built[Mesh.ARRAY_VERTEX] = out_v
	if has_normals:
		built[Mesh.ARRAY_NORMAL] = out_n
	built[Mesh.ARRAY_INDEX] = out_i
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, built)
	if skin != null:
		mesh.surface_set_material(0, skin)
	return {"mesh": mesh, "verts": out_v, "normals": out_n}


func _take_vert(index: int, verts: PackedVector3Array, normals: PackedVector3Array, has_normals: bool, baked: Transform3D, remap: PackedInt32Array, out_v: PackedVector3Array, out_n: PackedVector3Array) -> int:
	if remap[index] >= 0:
		return remap[index]
	var next: int = out_v.size()
	remap[index] = next
	out_v.append(baked * verts[index])
	if has_normals:
		out_n.append((baked.basis * normals[index]).normalized())
	return next


func _seat_mesh(mesh_node: MeshInstance3D, tip: Vector3) -> Vector3:
	var center: Vector3 = mesh_node.get_aabb().get_center()
	var s: float = HAND_SCALE
	# Fingers run along -Z and the palm faces +Y. Turn that into fingers +Y, palm +Z.
	var orient := Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0))
	var seated: Basis = orient.scaled(Vector3(s, s, s))
	mesh_node.transform = Transform3D(seated, -(seated * center))
	return seated * (tip - center)


func _skeleton_on(model: Node3D, positive: bool) -> Skeleton3D:
	var found: Skeleton3D = _find_skeleton(model, model, positive)
	return found


func _find_skeleton(model: Node3D, node: Node, positive: bool) -> Skeleton3D:
	if node is Skeleton3D:
		var skel: Skeleton3D = node as Skeleton3D
		var at: Vector3 = _chain(model, skel) * skel.get_bone_global_rest(0).origin
		if positive == (at.x > 0.0):
			return skel
	for child in node.get_children():
		var found: Skeleton3D = _find_skeleton(model, child, positive)
		if found != null:
			return found
	return null


func _curl_sign(rests: Array[Transform3D], parents: PackedInt32Array, names: PackedStringArray) -> float:
	var joint: int = names.find("Bone.011")
	var tip: int = names.find("Bone.012")
	if joint < 0 or tip < 0:
		return 1.0
	var moved: Vector3 = _bend_point(rests, parents, joint, rests[tip].origin, 1.0)
	if moved.y >= rests[tip].origin.y:
		return 1.0
	return -1.0


func _bend_point(rests: Array[Transform3D], parents: PackedInt32Array, joint: int, point: Vector3, angle: float) -> Vector3:
	var parent: int = parents[joint]
	var parent_rest: Transform3D = Transform3D.IDENTITY if parent < 0 else rests[parent]
	var rest_local: Transform3D = parent_rest.affine_inverse() * rests[joint]
	var spun: Basis = rest_local.basis * Basis(Vector3.RIGHT, angle)
	var posed: Transform3D = parent_rest * Transform3D(spun, rest_local.origin)
	return posed * rests[joint].affine_inverse() * point


func _bind_verts(verts: PackedVector3Array, rests: Array[Transform3D], parents: PackedInt32Array, names: PackedStringArray) -> PackedInt32Array:
	var bind := PackedInt32Array()
	bind.resize(verts.size())
	var starts: Array[Vector3] = []
	var ends: Array[Vector3] = []
	for b in rests.size():
		var origin: Vector3 = rests[b].origin
		starts.append(origin)
		ends.append(_bone_end(b, origin, rests, parents, names))
	for i in verts.size():
		var best: int = 0
		var best_d: float = 999999.0
		for b in rests.size():
			var dist: float = _segment_distance(verts[i], starts[b], ends[b])
			if dist < best_d:
				best_d = dist
				best = b
		bind[i] = best
	return bind


func _bone_end(b: int, origin: Vector3, rests: Array[Transform3D], parents: PackedInt32Array, names: PackedStringArray) -> Vector3:
	if names[b] == "Bone":
		return origin + Vector3(0, 0, -1.0)
	var child: int = -1
	for c in parents.size():
		if parents[c] == b:
			child = c
			break
	if child >= 0:
		return rests[child].origin
	var parent: int = parents[b]
	if parent < 0:
		return origin + Vector3(0, 0, -0.35)
	var dir: Vector3 = origin - rests[parent].origin
	if dir.length_squared() < 0.0001:
		return origin
	return origin + dir.normalized() * 0.42


func _segment_distance(point: Vector3, a: Vector3, b: Vector3) -> float:
	var span: Vector3 = b - a
	var len2: float = span.length_squared()
	if len2 < 0.0001:
		return point.distance_to(a)
	var t: float = clampf((point - a).dot(span) / len2, 0.0, 1.0)
	return point.distance_to(a + span * t)


func _index_tip(verts: PackedVector3Array, bind: PackedInt32Array, names: PackedStringArray) -> Vector3:
	var tip_bone: int = names.find("Bone.009")
	var best: Vector3 = Vector3.ZERO
	var best_z: float = 999.0
	var found: bool = false
	for i in verts.size():
		if tip_bone >= 0 and bind[i] != tip_bone:
			continue
		if verts[i].z < best_z:
			best_z = verts[i].z
			best = verts[i]
			found = true
	if found:
		return best
	return verts[0] if verts.size() > 0 else Vector3.ZERO


func _deform_mesh(rest_mesh: ArrayMesh, verts: PackedVector3Array, normals: PackedVector3Array, bind: PackedInt32Array, rests: Array[Transform3D], parents: PackedInt32Array, names: PackedStringArray, sign: float, skin: Material) -> ArrayMesh:
	var posed: Array[Transform3D] = _point_globals(rests, parents, names, sign)
	var out_v := PackedVector3Array()
	var out_n := PackedVector3Array()
	out_v.resize(verts.size())
	var has_normals: bool = normals.size() == verts.size()
	if has_normals:
		out_n.resize(verts.size())
	for i in verts.size():
		var bone: int = bind[i]
		var skin_xform: Transform3D = posed[bone] * rests[bone].affine_inverse()
		out_v[i] = skin_xform * verts[i]
		if has_normals:
			out_n[i] = (skin_xform.basis * normals[i]).normalized()
	var indices: PackedInt32Array = rest_mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	var mesh := ArrayMesh.new()
	var built: Array = []
	built.resize(Mesh.ARRAY_MAX)
	built[Mesh.ARRAY_VERTEX] = out_v
	if has_normals:
		built[Mesh.ARRAY_NORMAL] = out_n
	built[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, built)
	if skin != null:
		mesh.surface_set_material(0, skin)
	return mesh


func _point_globals(rests: Array[Transform3D], parents: PackedInt32Array, names: PackedStringArray, sign: float) -> Array[Transform3D]:
	var globals: Array[Transform3D] = []
	globals.resize(rests.size())
	for b in rests.size():
		var parent: int = parents[b]
		var parent_rest: Transform3D = Transform3D.IDENTITY if parent < 0 else rests[parent]
		var parent_posed: Transform3D = Transform3D.IDENTITY if parent < 0 else globals[parent]
		var rest_local: Transform3D = parent_rest.affine_inverse() * rests[b]
		var angle: float = _point_angle(names[b]) * sign
		var spun: Basis = rest_local.basis * Basis(Vector3.RIGHT, angle)
		globals[b] = parent_posed * Transform3D(spun, rest_local.origin)
	return globals


func _point_angle(bone_name: String) -> float:
	match bone_name:
		"Bone.001":
			return 1.15
		"Bone.010", "Bone.002":
			return 1.35
		"Bone.011", "Bone.013", "Bone.003":
			return 1.2
		"Bone.012", "Bone.015", "Bone.018":
			return 0.85
		"Bone.014", "Bone.016":
			return 1.3
		"Bone.017":
			return 1.1
		"Bone.005":
			return 0.85
		"Bone.006":
			return 1.05
		_:
			return 0.0


func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		if mesh_node.mesh != null:
			return mesh_node
	for child in node.get_children():
		var found: MeshInstance3D = _find_mesh(child)
		if found != null:
			return found
	return null


func _chain(model: Node3D, mesh_node: Node3D) -> Transform3D:
	var xform := Transform3D.IDENTITY
	var node: Node3D = mesh_node
	while node != model and node != null:
		xform = node.transform * xform
		node = node.get_parent() as Node3D
	return xform


func _soften(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var mat: Material = mesh_node.get_active_material(0)
		if mat != null:
			var copy: Material = mat.duplicate()
			if copy is StandardMaterial3D:
				var skin := copy as StandardMaterial3D
				skin.metallic = 0.0
				skin.roughness = 0.68
				skin.metallic_texture = null
				skin.roughness_texture = null
				skin.cull_mode = BaseMaterial3D.CULL_DISABLED
				mesh_node.set_surface_override_material(0, skin)
				_skin_mats.append(skin)
				_skin_tex.append(skin.albedo_texture)
				_skin_color.append(skin.albedo_color)
	for child in node.get_children():
		_soften(child)


func set_tone(index: int) -> void:
	var tone := Color.WHITE
	var flat := index > 0 and index < Game.SKIN_COLOR.size()
	if flat:
		tone = Game.SKIN_COLOR[index]
	for i in _skin_mats.size():
		var mat := _skin_mats[i]
		if flat:
			mat.albedo_texture = null
			mat.albedo_color = tone
		else:
			mat.albedo_texture = _skin_tex[i]
			mat.albedo_color = _skin_color[i]
