extends RigidBody3D

signal rolled(value: int)

const FACE: Array[Vector3] = [
	Vector3(0, -0.333333, 0.942809),
	Vector3(-0.816497, -0.333333, -0.471405),
	Vector3(0.816497, -0.333333, -0.471405),
	Vector3(0, 1, 0),
]

var rolling: bool = false
var face: int = 0


func roll() -> void:
	rolling = true
	position = Vector3(2.7, 1.6, 2.2)
	rotation = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))
	linear_velocity = Vector3(-5, 0, 0)
	angular_velocity = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))


#func _process(delta) -> void:
	#DebugDraw3D.draw_arrow(position, position + quaternion * FACE[0], Color.RED)
	#DebugDraw3D.draw_arrow(position, position + quaternion * FACE[1], Color.YELLOW)
	#DebugDraw3D.draw_arrow(position, position + quaternion * FACE[2], Color.GREEN)
	#DebugDraw3D.draw_arrow(position, position + quaternion * FACE[3], Color.BLUE)
	#DebugDraw3D.draw_arrow(position, position + Vector3.UP, Color.WHITE)


func _physics_process(_delta: float) -> void:
	face = 1
	var angle := -1.0
	var angles: Array[float] = []
	for i in range(0, 4):
		var a := Vector3.UP.dot(quaternion * FACE[i])
		angles.push_back(a)
		if a > angle:
			face = i
			angle = a
	
	if rolling and linear_velocity.length_squared() < .01 and angular_velocity.length_squared() < .01:
		rolling = false
		rolled.emit(face)


func _input_event(_camera: Camera3D, event: InputEvent, _position_: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var did_click: bool = false
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		did_click = mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed
	
	if did_click:
		roll()
