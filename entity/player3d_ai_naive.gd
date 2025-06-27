class_name Player3DAINaive
extends Player3D


func _pick_move(_game_logic: GameLogic, moves: Array[GameLogic.Move]) -> GameLogic.Move:
	return moves.pick_random()