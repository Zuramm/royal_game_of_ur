extends Area3D


signal selected

@export var thickness: float = 0.2
@export var positions: Array[Vector3]
@export var start_position: int
@export var end_position: int
@export var does_kill: bool

@export var board_shape: Shape3D
@export var board_offset: Vector3
@export var left_shape: Shape3D
@export var left_position: Vector3


func _ready():
	if positions == null or positions.is_empty() \
	or start_position == end_position:
		return
	
	if start_position == 0:
		$CollisionShape3D.shape = left_shape
		$CollisionShape3D.position = left_position
	else:
		$CollisionShape3D.shape = board_shape
		$CollisionShape3D.position = positions[start_position] + board_offset
	$Highlight.width = $CollisionShape3D.shape.size.x
	$Highlight.height = $CollisionShape3D.shape.size.z
	$Highlight.position = $CollisionShape3D.position
	$Highlight.material_override = preload("res://move_material.tres")
	$Highlight.update_mesh()
	
	$MeshInstance3D.visible = false
	if does_kill:
		$MeshInstance3D.material_override = preload("res://move_kill_material.tres")
		$Highlight.material_override = preload("res://move_kill_material.tres")
	update_path()


func _mouse_enter():
	$MeshInstance3D.visible = true


func _mouse_exit():
	$MeshInstance3D.visible = false


func _input_event(_camera, event, _position_, _normal, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed \
	or event is InputEventScreenTouch \
	and event.pressed:
		selected.emit()


func update_path():
	var mesh = $MeshInstance3D.mesh
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var start = maxi(0, start_position)
	var end = end_position
	
	for i in range(start, end + 1):
		var p1 = positions[max(0, i - 1)]
		var p2 = positions[i]
		var p3 = positions[min(i + 1, len(positions) - 1)]
		var v1 = (p2 - p1).normalized()
		var v2 = (p3 - p2).normalized()
		var across = ((v1 + v2) / 2.0).normalized().cross(Vector3(0, -1, 0))
		mesh.surface_add_vertex(p2 - across * thickness / 2)
		mesh.surface_add_vertex(p2 + across * thickness / 2)
	
	mesh.surface_end()
