extends MarginContainer


@onready var _setup_scene = preload("res://scene/game.tscn")


func _on_dice_option_button_item_selected(index: int) -> void:
	GameParameters.dice = [GameTypes.DICE_D4x1, GameTypes.DICE_D3x2, GameTypes.DICE_D2x3, GameTypes.DICE_D2x4][index]


func _on_path_option_button_item_selected(index: int) -> void:
	GameParameters.path = [GameTypes.PATH_BELL, GameTypes.PATH_MASTER, GameTypes.PATH_MURRAY, GameTypes.PATH_SKIRIUK][index]


func _on_pieces_slider_value_changed(value: float) -> void:
	GameParameters.pieces = round(value)


func _on_rosette_safe_toggled(toggled_on: bool) -> void:
	GameParameters.rosette_safe = toggled_on


func _on_rosette_extra_turn_toggled(toggled_on: bool) -> void:
	GameParameters.rosette_extra_turn = toggled_on


func _on_capture_extra_turn_toggled(toggled_on: bool) -> void:
	GameParameters.capture_extra_turn = toggled_on


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(_setup_scene)
