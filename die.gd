extends RigidBody3D

signal rolled(int)

const FACE: Array[Vector3] = [
	Vector3(0, -0.333333, 0.942809),
	Vector3(-0.816497, -0.333333, -0.471405),
	Vector3(0.816497, -0.333333, -0.471405),
	Vector3(0, 1, 0),
]

var rolling: bool = false
var face: int = 0


func roll():
	rolling = true
	position = Vector3(2.7, 1.6, 2.2)
	linear_velocity = Vector3(-2, 0, 0)
	angular_velocity = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))


func _physics_process(delta):
	face = 1
	var angle = Vector3.DOWN.dot(transform * FACE[0])
	for i in range(2, 4):
		var a = Vector3.DOWN.dot(transform * FACE[i - 1])
		if a < angle:
			face = i
			angle = a
	
	if rolling and linear_velocity.length_squared() < .1 and angular_velocity.length_squared() < .01:
		rolling = false
		rolled.emit(face)
		print([Vector3.DOWN.dot(transform * FACE[0]), Vector3.DOWN.dot(transform * FACE[1]), Vector3.DOWN.dot(transform * FACE[2]), Vector3.DOWN.dot(transform * FACE[3])])


func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		roll()
