extends MarginContainer


@onready var _setup_scene: PackedScene = preload("res://scene/game.tscn")


const DICE: Array[int] = [GameTypes.DICE_D4x1, GameTypes.DICE_D3x2, GameTypes.DICE_D2x3, GameTypes.DICE_D2x4]
const PATHS := [GameTypes.Path.BELL, GameTypes.Path.MASTER, GameTypes.Path.MURRAY, GameTypes.Path.SKIRIUK]


func _ready() -> void:
	%DiceOptionButton.selected = DICE.find(GameParameters.dice)
	%PathOptionButton.selected = PATHS.find(GameParameters.path)
	%PiecesSlider.value = GameParameters.pieces
	%RosetteSafe.button_pressed = GameParameters.rosette_safe
	%RosetteExtraTurn.button_pressed = GameParameters.rosette_extra_turn
	%CaptureExtraTurn.button_pressed = GameParameters.capture_extra_turn


func _on_dice_option_button_item_selected(index: int) -> void:
	GameParameters.dice = DICE[index]


func _on_path_option_button_item_selected(index: int) -> void:
	GameParameters.path = PATHS[index]


func _on_pieces_slider_value_changed(value: float) -> void:
	GameParameters.pieces = roundi(value)


func _on_rosette_safe_toggled(toggled_on: bool) -> void:
	GameParameters.rosette_safe = toggled_on


func _on_rosette_extra_turn_toggled(toggled_on: bool) -> void:
	GameParameters.rosette_extra_turn = toggled_on


func _on_capture_extra_turn_toggled(toggled_on: bool) -> void:
	GameParameters.capture_extra_turn = toggled_on


func _on_start_button_pressed() -> void:
	var result := get_tree().change_scene_to_packed(_setup_scene)
	if result != OK:
		push_error("Failed to load game scene: ", error_string(result))
