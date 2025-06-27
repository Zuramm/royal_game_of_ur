class_name AISmart
extends AI

# Scoring weights for different move types
const WEIGHT_SAFE_PIECE = 1000
const WEIGHT_CAPTURE = 300
const WEIGHT_EXTRA_TURN = 200
const WEIGHT_ROSETTE = 50
const WEIGHT_PROGRESS = 30
const WEIGHT_BLOCKING = 25
const WEIGHT_PIECE_LEFT = -15

func pick_move(game_logic: GameLogic) -> GameLogic.Move:
	var moves := game_logic.moves
	if moves.is_empty():
		return null
	
	var best_move: GameLogic.Move = null
	var best_score := -INF
	
	for move in moves:
		var score := _evaluate_move(move, game_logic)
		
		# Apply the move to see the resulting position
		var game_copy := game_logic.clone()
		move.apply(game_copy.current_player, game_copy.opponent_player)
		
		# Add position evaluation bonus
		score += _evaluate_position_bonus(game_copy)
		
		if score > best_score:
			best_score = score
			best_move = move
	
	return best_move

func _evaluate_move(move: GameLogic.Move, game_logic: GameLogic) -> float:
	var score := 0.0
	
	if move is GameLogic.MoveOntoBoard:
		var move_onto := move as GameLogic.MoveOntoBoard
		
		# Base score for getting a piece on the board
		score += 100
		
		# Bonus for progress (further along the path is better)
		score += move_onto._target_progress * WEIGHT_PROGRESS
		
		# Bonus for capturing opponent piece
		if move_onto.does_kill:
			score += WEIGHT_CAPTURE
		
		# Bonus for extra turn
		if move_onto.grants_extra_turn:
			score += WEIGHT_EXTRA_TURN
		
		# Bonus for landing on rosette (safe position)
		if move_onto.target_position in game_logic.rosettes:
			score += WEIGHT_ROSETTE
		
		# Bonus for blocking opponent's path
		score += _evaluate_blocking_bonus(move_onto.target_position, game_logic)
		
	elif move is GameLogic.MoveOnBoard:
		var move_on := move as GameLogic.MoveOnBoard
		
		# Base score for movement
		score += 50
		
		# Bonus for progress (further along the path is better)
		score += (move_on._target_progress - move_on._piece_progress) * WEIGHT_PROGRESS
		
		# Bonus for capturing opponent piece
		if move_on.does_kill:
			score += WEIGHT_CAPTURE
		
		# Bonus for extra turn
		if move_on.grants_extra_turn:
			score += WEIGHT_EXTRA_TURN
		
		# Bonus for landing on rosette (safe position)
		if move_on.target_position in game_logic.rosettes:
			score += WEIGHT_ROSETTE
		
		# Bonus for blocking opponent's path
		score += _evaluate_blocking_bonus(move_on.target_position, game_logic)
		
	elif move is GameLogic.MoveFromBoard:
		var move_from := move as GameLogic.MoveFromBoard
		
		# High priority for getting pieces to safety
		score += WEIGHT_SAFE_PIECE
		
		# Bonus for getting pieces that are further along the path to safety
		score += move_from._piece_progress * WEIGHT_PROGRESS
	
	return score

func _evaluate_position_bonus(game_logic: GameLogic) -> float:
	var score := 0.0
	
	# Evaluate from current player's perspective
	var current := game_logic.current_player
	var opponent := game_logic.opponent_player
	
	# Bonus for having more pieces safely at the end
	score += current.pieces_safe * WEIGHT_SAFE_PIECE
	score -= opponent.pieces_safe * WEIGHT_SAFE_PIECE
	
	# Bonus for pieces further along the path
	for progress in current.pieces_progress:
		score += progress * WEIGHT_PROGRESS
	
	for progress in opponent.pieces_progress:
		score -= progress * WEIGHT_PROGRESS
	
	# Penalty for having too many pieces in hand
	score += current.pieces_left * WEIGHT_PIECE_LEFT
	score -= opponent.pieces_left * WEIGHT_PIECE_LEFT
	
	# Bonus for pieces on rosette positions
	for progress in current.pieces_progress:
		var position := current.path[progress]
		if position in game_logic.rosettes:
			score += WEIGHT_ROSETTE
	
	for progress in opponent.pieces_progress:
		var position := opponent.path[progress]
		if position in game_logic.rosettes:
			score -= WEIGHT_ROSETTE
	
	return score

func _evaluate_blocking_bonus(position: int, game_logic: GameLogic) -> float:
	var score := 0.0
	var current := game_logic.current_player
	var opponent := game_logic.opponent_player
	
	# Check if this position blocks any opponent pieces
	for opp_progress in opponent.pieces_progress:
		var opp_position := opponent.path[opp_progress]
		
		# If opponent piece is behind this position and we're blocking their path
		if _is_blocking_path(position, opp_position, opponent.path):
			score += WEIGHT_BLOCKING
	
	return score

func _is_blocking_path(blocker_pos: int, target_pos: int, path: Array[int]) -> bool:
	var target_index := path.find(target_pos)
	var blocker_index := path.find(blocker_pos)
	
	if target_index == -1 or blocker_index == -1:
		return false
	
	# Check if blocker is ahead of target on the path
	return blocker_index > target_index