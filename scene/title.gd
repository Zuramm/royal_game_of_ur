extends CenterContainer


@onready var _setup_scene = preload("res://scene/setup.tscn")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(_setup_scene)
