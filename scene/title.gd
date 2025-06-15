extends CenterContainer


@onready var _setup_scene: PackedScene = preload("res://scene/setup.tscn")


func _on_start_button_pressed() -> void:
	var result := get_tree().change_scene_to_packed(_setup_scene)
	if result != OK:
		push_error("Failed to load setup scene: ", error_string(result))
