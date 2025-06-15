class_name BoardMove
extends Area3D


signal selected

@export var thickness: float = 0.2
@export var positions: Array[Vector3]
@export var start_position: int
@export var end_position: int
@export var does_kill: bool

@export var board_shape: BoxShape3D
@export var board_offset: Vector3
@export var left_shape: BoxShape3D
@export var left_position: Vector3

@onready var _collision_node := $CollisionShape3D as CollisionShape3D
@onready var _mesh_node := $MeshInstance3D as MeshInstance3D
@onready var _highlight_node := $Highlight as Highlight

func _ready() -> void:
	if positions == null or positions.is_empty() \
	or start_position == end_position:
		return
	
	var collision_shape: BoxShape3D
	var collision_position: Vector3
	if start_position == 0:
		collision_shape = left_shape
		collision_position = left_position
	else:
		collision_shape = board_shape
		collision_position = positions[start_position] + board_offset
	_collision_node.shape = collision_shape
	_collision_node.position = collision_position
	_highlight_node.width = collision_shape.size.x
	_highlight_node.height = collision_shape.size.z
	_highlight_node.position = collision_position
	_highlight_node.material_override = preload("res://entity/board_move_material.tres")
	_highlight_node.update_mesh()
	
	_mesh_node.visible = false
	if does_kill:
		_mesh_node.material_override = preload("res://entity/board_move_material_kill.tres")
		_highlight_node.material_override = _mesh_node.material_override
	update_path()


func _mouse_enter() -> void:
	_mesh_node.visible = true


func _mouse_exit() -> void:
	_mesh_node.visible = false


func _input_event(_camera: Camera3D, event: InputEvent, _position_: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var did_click: bool = false
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		did_click = mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed
	
	if did_click:
		print(event)
		selected.emit()


func update_path() -> void:
	var mesh := _mesh_node.mesh as ImmediateMesh
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var start := maxi(0, start_position)
	var end := end_position
	
	for i in range(start, end + 1):
		var p1 := positions[max(0, i - 1)]
		var p2 := positions[i]
		var p3 := positions[min(i + 1, len(positions) - 1)]
		var v1 := (p2 - p1).normalized()
		var v2 := (p3 - p2).normalized()
		var across := ((v1 + v2) / 2.0).normalized().cross(Vector3(0, -1, 0))
		mesh.surface_add_vertex(p2 - across * thickness / 2)
		mesh.surface_add_vertex(p2 + across * thickness / 2)
	
	mesh.surface_end()
