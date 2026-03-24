@tool
class_name BoardMove
extends Area3D


signal selected


@export var thickness: float = 0.2
@export var positions: Array[Vector3]:
	set(value):
		positions = value
		if Engine.is_editor_hint() and is_inside_tree():
			update_path()

@export var does_kill: bool

@export var collision_shape: BoxShape3D
@export var collision_position: Vector3

@onready var _collision_node := $CollisionShape3D as CollisionShape3D
@onready var _mesh_node := $MeshInstance3D as MeshInstance3D


func _ready() -> void:
	if positions == null or positions.is_empty() \
	or positions.size() < 2:
		push_error("Invalid positions: ", positions)
		return

	if collision_shape == null or Engine.is_editor_hint():
		_mesh_node.visible = true
	else:
		_collision_node.shape = collision_shape
		_collision_node.position = collision_position
		_mesh_node.visible = false
	
	if does_kill:
		_mesh_node.material_override = preload("res://entity/board_move_material_kill.tres")
	
	update_path()


func _mouse_enter() -> void:
	if not Engine.is_editor_hint():
		_mesh_node.visible = true


func _mouse_exit() -> void:
	if not Engine.is_editor_hint():
		_mesh_node.visible = false


func _input_event(_camera: Camera3D, event: InputEvent, _position_: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var did_click: bool = false
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		did_click = mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed
	
	if did_click:
		selected.emit()


func _sanitized_positions() -> Array[Vector3]:
	var sanitized: Array[Vector3] = [positions[0]]

	for p in positions:
		if sanitized.size() == 0:
			sanitized.push_back(p)
		elif sanitized.size() == 1:
			var p1 := sanitized[sanitized.size() - 1]
			var p2 := p
			if p1.distance_to(p2) > 0.000001:
				sanitized.push_back(p)
		else:
			var p1 := sanitized[sanitized.size() - 2]
			var p2 := sanitized[sanitized.size() - 1]
			var p3 := p
			var v1 := (p2 - p1).normalized()
			var v2 := (p3 - p2).normalized()
			if p1.distance_to(p2) > 0.000001 and v1.dot(v2) < 0.999999:
				sanitized.push_back(p)
			else:
				sanitized.pop_back()
				sanitized.push_back(p)

	return sanitized

func update_path() -> void:
	if positions == null or positions.size() < 2:
		push_error("Invalid positions: ", positions)
		return

	var sanitized: Array[Vector3] = _sanitized_positions()

	if sanitized.size() < 2:
		push_error("Invalid sanitized positions: ", sanitized)
		return

	print("update_path", sanitized)

	var mesh := _mesh_node.mesh as ImmediateMesh

	mesh.clear_surfaces()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var p1: Vector3
	var p2: Vector3
	var p3: Vector3
	var v1: Vector3
	var v2: Vector3
	var w1: Vector3
	var w2: Vector3
	var left: Vector3
	var right: Vector3

	p1 = sanitized[0]
	p2 = sanitized[1]
	v1 = (p2 - p1).normalized()
	w1 = v1.rotated(Vector3.UP, PI / 2) * thickness / 2
	left = p1 - w1
	right = p1 + w1
	print("left: ", left, "right: ", right)
	mesh.surface_add_vertex(left)
	mesh.surface_add_vertex(right)

	for i in range(1, sanitized.size() - 1):
		p1 = sanitized[i - 1]
		p2 = sanitized[i]
		p3 = sanitized[i + 1]
		v1 = (p2 - p1).normalized()
		v2 = (p3 - p2).normalized()
		w1 = v1.rotated(Vector3.UP, PI / 2) * thickness / 2
		w2 = v2.rotated(Vector3.UP, PI / 2) * thickness / 2
		left = _calculate_intersection(p1 - w1, v1, p2 - w2, v2)
		right = _calculate_intersection(p1 + w1, v1, p2 + w2, v2)
		if left == Vector3.INF or right == Vector3.INF:
			continue
		print("left: ", left, "right: ", right)
		mesh.surface_add_vertex(left)
		mesh.surface_add_vertex(right)

	p1 = sanitized[sanitized.size() - 2]
	p2 = sanitized[sanitized.size() - 1]
	v1 = (p2 - p1).normalized()
	w1 = v1.rotated(Vector3.UP, PI / 2) * thickness / 2
	left = p2 - w1
	right = p2 + w1
	print("left: ", left, "right: ", right)
	mesh.surface_add_vertex(left)
	mesh.surface_add_vertex(right)

	mesh.surface_end()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	v1 *= sqrt(2) * thickness / 2
	w1 *= sqrt(2)

	left = p2 - 2.5 * v1 - 3.5 * w1
	right = p2 - 3.5 * v1 - 2.5 * w1
	mesh.surface_add_vertex(left)
	mesh.surface_add_vertex(right)

	left = p2 + 1.0 * v1
	right = p2 - 1.0 * v1
	mesh.surface_add_vertex(left)
	mesh.surface_add_vertex(right)

	left = p2 - 2.5 * v1 + 3.5 * w1
	right = p2 - 3.5 * v1 + 2.5 * w1
	mesh.surface_add_vertex(left)
	mesh.surface_add_vertex(right)

	mesh.surface_end()

func _calculate_intersection(p1: Vector3, v1: Vector3, p2: Vector3, v2: Vector3) -> Vector3:
	var cross := v1.cross(v2)
	if cross.length_squared() < 0.000001:
		return Vector3.INF

	var diff := p2 - p1
	var t := diff.cross(v2).dot(cross) / cross.length_squared()

	return p1 + v1 * t
