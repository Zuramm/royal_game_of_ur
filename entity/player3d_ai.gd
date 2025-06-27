class_name Player3DAI
extends Player3D


var ai: AI


func _pick_move(game_logic: GameLogic) -> GameLogic.Move:
	return ai.pick_move(game_logic)