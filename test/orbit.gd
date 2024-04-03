extends Node3D

# radians per second
@export var mouse_sensitivity: float = 0.01


func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var offset = Input.get_last_mouse_velocity() * delta * mouse_sensitivity
		rotation += Vector3(-offset.y, offset.x, 0.0)
