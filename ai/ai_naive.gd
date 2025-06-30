class_name AINaive
extends AI


func pick_move(game_logic: GameLogic) -> GameLogic.Move:
	var moves := game_logic.moves
	if moves.is_empty():
		return null
	return moves.pick_random()
