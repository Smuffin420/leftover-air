extends CharacterBody3D
class_name PopWorker

var block_move: bool = false
var block_look: bool = false
var carrying: bool = false
var yaw: float = 0.0
var pitch: float = 0.0

var _carry: MeshInstance3D
var _carry_mat: StandardMaterial3D
var _hands: ViewHands
var _tool: int = 0
var _look_pending: Vector2 = Vector2.ZERO
var _sprint_latched: bool = false
var _bob_t: float = 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	add_child(shape)
	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.position = Vector3(0, 0.55, 0)
	cam.current = true
	cam.fov = Settings.fov
	add_child(cam)
	_carry = MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.085
	mesh.bottom_radius = 0.085
	mesh.height = 0.36
	mesh.radial_segments = 20
	_carry.mesh = mesh
	_carry.position = Vector3(0, -0.14, -0.48)
	_carry.rotation_degrees = Vector3(90, 0, 90)
	_carry_mat = StandardMaterial3D.new()
	_carry_mat.albedo_color = Color("8fd0ea")
	_carry_mat.roughness = 0.45
	_carry.material_override = _carry_mat
	_carry.visible = false
	_carry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cam.add_child(_carry)
	_hands = ViewHands.new()
	cam.add_child(_hands)
	_hands.bind_roll(_carry)


func set_carry(mode: int, tint: Color = Color("8fd0ea")) -> void:
	carrying = mode != 0
	_carry.visible = carrying
	if _hands != null:
		_hands.set_carry(mode)
	if mode == 2:
		_carry_mat.albedo_color = tint.lerp(Color("c4b8a4"), 0.72)
	elif mode == 1:
		_carry_mat.albedo_color = tint


func set_working(active: bool) -> void:
	if _hands != null:
		_hands.set_working(active)
		_hands.set_tool(_tool)


func set_tool(which: int) -> void:
	_tool = which
	if _hands != null:
		_hands.set_tool(which)


func set_skin(index: int) -> void:
	if _hands != null:
		_hands.set_tone(index)


func set_hands_visible(show_hands: bool) -> void:
	if _hands != null:
		_hands.visible = show_hands


func set_table_hands(active: bool) -> void:
	if _hands != null:
		_hands.set_table(active)


func aim_table(point: Vector3) -> void:
	if _hands != null:
		_hands.aim_table(point)


func aim_pair(right_point: Vector3, left_point: Vector3) -> void:
	if _hands != null:
		_hands.aim_pair(right_point, left_point)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and Settings.sprint_toggle and Settings.pressed(key_event, "sprint") and not block_move:
			_sprint_latched = not _sprint_latched
	if block_look:
		_look_pending = Vector2.ZERO
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		_look_pending += motion.relative


func _physics_process(delta: float) -> void:
	_apply_look(delta)
	var speed: float = Game.move_speed()
	var sprinting: bool = _sprint_latched if Settings.sprint_toggle else Settings.held("sprint")
	if sprinting:
		speed *= Game.sprint_mult()
	if carrying:
		speed *= Game.carry_mult()
	var wish := Vector3.ZERO
	if not block_move:
		var basis_now: Basis = global_transform.basis
		if Settings.held("forward"):
			wish -= basis_now.z
		if Settings.held("back"):
			wish += basis_now.z
		if Settings.held("right"):
			wish += basis_now.x
		if Settings.held("left"):
			wish -= basis_now.x
		wish.y = 0.0
		if wish.length() > 0.01:
			wish = wish.normalized() * speed
	var accel: float = 40.0 if block_move else Game.grip_accel()
	velocity.x = move_toward(velocity.x, wish.x, accel * delta)
	velocity.z = move_toward(velocity.z, wish.z, accel * delta)
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = -1.0
	move_and_slide()


func _apply_look(delta: float) -> void:
	var follow := 1.0
	if Settings.mouse_smooth > 0.01:
		follow = clampf(1.0 - Settings.mouse_smooth * 0.9, 0.08, 1.0)
	var step := _look_pending * follow
	_look_pending -= step
	if block_look:
		_look_pending = Vector2.ZERO
		step = Vector2.ZERO
	var x_sign := -1.0 if Settings.invert_x else 1.0
	var y_sign := -1.0 if Settings.invert_y else 1.0
	yaw -= step.x * Settings.sens_x * x_sign
	pitch -= step.y * Settings.sens_y * y_sign
	pitch = clampf(pitch, -1.15, 1.15)
	rotation.y = yaw
	var camera := $Camera3D as Camera3D
	camera.rotation.x = pitch
	camera.fov = Settings.fov
	var bob := 0.0
	var moving := Vector2(velocity.x, velocity.z).length()
	if Settings.view_bob_scale() > 0.0 and not block_move and moving > 0.35:
		_bob_t += delta * moving * 1.7
		bob = sin(_bob_t) * 0.018 * Settings.view_bob_scale()
	camera.position.y = 0.55 + bob
