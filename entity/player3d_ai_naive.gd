class_name Player3DAINaive
extends Player3D


func _pick_move(moves: Array[GameLogic.Move]) -> GameLogic.Move:
	return moves.pick_random()