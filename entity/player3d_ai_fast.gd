class_name Player3DAIFast
extends Player3D


func _pick_move(_game_logic: GameLogic, moves: Array[GameLogic.Move]) -> GameLogic.Move:
	var best_move: GameLogic.Move = null
	var best_score: int = -1

	for move in moves:
		var score: int = _score_move(move)
		if score > best_score:
			best_score = score
			best_move = move
	
	return best_move


func _score_move(move: GameLogic.Move) -> int:
	var score := 0

	if move is GameLogic.MoveOntoBoard:
		var move_onto := move as GameLogic.MoveOntoBoard
		if move_onto.grants_extra_turn:
			score += 1
		score += move_onto._target_progress * 2
		if move_onto.does_kill:
			score += GameParameters.board_positions.size() * 2
	elif move is GameLogic.MoveOnBoard:
		var move_on := move as GameLogic.MoveOnBoard
		if move_on.grants_extra_turn:
			score += 1
		score += move_on._target_progress * 2
		if move_on.does_kill:
			score += GameParameters.board_positions.size() * 2
	elif move is GameLogic.MoveFromBoard:
		var move_from := move as GameLogic.MoveFromBoard
		score += GameParameters.board_positions.size()
		score += move_from._piece_progress
	else:
		push_error("Invalid move: ", move)

	return score