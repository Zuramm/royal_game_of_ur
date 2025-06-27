class_name AICursor
extends AI

# AI configuration
const MAX_DEPTH = 4
const ALPHA_BETA_PRUNING = true

# Scoring weights
const WEIGHT_PIECE_SAFE = 1000
const WEIGHT_PIECE_PROGRESS = 50
const WEIGHT_CAPTURE = 200
const WEIGHT_EXTRA_TURN = 150
const WEIGHT_ROSETTE = 30
const WEIGHT_BLOCKING_OPPONENT = 25
const WEIGHT_PIECE_LEFT = -10

func pick_move(game_logic: GameLogic) -> GameLogic.Move:
	var moves := game_logic.moves
	if moves.is_empty():
		return null
	
	var best_move: GameLogic.Move = null
	var best_score := -INF
	var alpha := -INF
	var beta := INF
	
	for move in moves:
		# Apply the move to a copy of the game state
		var game_copy := game_logic.clone()
		move.apply(game_copy.current_player, game_copy.opponent_player)
		
		# If the move grants an extra turn, we need to continue evaluating
		if move.grants_extra_turn:
			# Continue with the same player's turn
			var score := _minimax(game_copy, MAX_DEPTH - 1, false, alpha, beta)
			if score > best_score:
				best_score = score
				best_move = move
		else:
			# Switch to opponent's turn
			game_copy._current_player_color = (1 - game_copy._current_player_color as int) as GameLogic.PlayerColor
			var score := _minimax(game_copy, MAX_DEPTH - 1, false, alpha, beta)
			if score > best_score:
				best_score = score
				best_move = move
		
		# Alpha-beta pruning
		if ALPHA_BETA_PRUNING:
			alpha = max(alpha, best_score)
			if alpha >= beta:
				break
	
	return best_move

func _minimax(game_logic: GameLogic, depth: int, is_maximizing: bool, alpha: float, beta: float) -> float:
	# Terminal conditions
	if depth == 0 or game_logic.is_game_over:
		return _evaluate_position(game_logic)
	
	# Generate all possible moves for current player
	var die_rolls := _get_possible_die_rolls()
	var all_moves: Array[GameLogic.Move] = []
	
	for die in die_rolls:
		var game_copy := game_logic.clone()
		game_copy.roll_die(die)
		all_moves.append_array(game_copy.moves)
	
	if all_moves.is_empty():
		# No moves available, evaluate current position
		return _evaluate_position(game_logic)
	
	if is_maximizing:
		var max_score := -INF
		for move in all_moves:
			var game_copy := game_logic.clone()
			move.apply(game_copy.current_player, game_copy.opponent_player)
			
			var score: float
			if move.grants_extra_turn:
				score = _minimax(game_copy, depth - 1, true, alpha, beta)
			else:
				game_copy._current_player_color = (1 - game_copy._current_player_color as int) as GameLogic.PlayerColor
				score = _minimax(game_copy, depth - 1, false, alpha, beta)
			
			max_score = max(max_score, score)
			
			if ALPHA_BETA_PRUNING:
				alpha = max(alpha, max_score)
				if alpha >= beta:
					break
		
		return max_score
	else:
		var min_score := INF
		for move in all_moves:
			var game_copy := game_logic.clone()
			move.apply(game_copy.current_player, game_copy.opponent_player)
			
			var score: float
			if move.grants_extra_turn:
				score = _minimax(game_copy, depth - 1, false, alpha, beta)
			else:
				game_copy._current_player_color = (1 - game_copy._current_player_color as int) as GameLogic.PlayerColor
				score = _minimax(game_copy, depth - 1, true, alpha, beta)
			
			min_score = min(min_score, score)
			
			if ALPHA_BETA_PRUNING:
				beta = min(beta, min_score)
				if alpha >= beta:
					break
		
		return min_score

func _evaluate_position(game_logic: GameLogic) -> float:
	var score := 0.0
	
	# Evaluate from the perspective of the original player (white)
	var white_player := game_logic._white_player
	var black_player := game_logic._black_player
	
	# Check for game over
	if white_player.is_done:
		return 10000 # White wins
	elif black_player.is_done:
		return -10000 # Black wins
	
	# Score based on pieces that have reached the end safely
	score += white_player.pieces_safe * WEIGHT_PIECE_SAFE
	score -= black_player.pieces_safe * WEIGHT_PIECE_SAFE
	
	# Score based on progress of pieces on the board
	for progress in white_player.pieces_progress:
		score += progress * WEIGHT_PIECE_PROGRESS
	
	for progress in black_player.pieces_progress:
		score -= progress * WEIGHT_PIECE_PROGRESS
	
	# Score based on pieces still in hand (negative - fewer is better)
	score += white_player.pieces_left * WEIGHT_PIECE_LEFT
	score -= black_player.pieces_left * WEIGHT_PIECE_LEFT
	
	# Bonus for pieces on rosette positions (safe positions)
	for progress in white_player.pieces_progress:
		var position := white_player.path[progress]
		if position in game_logic.rosettes:
			score += WEIGHT_ROSETTE
	
	for progress in black_player.pieces_progress:
		var position := black_player.path[progress]
		if position in game_logic.rosettes:
			score -= WEIGHT_ROSETTE
	
	# Bonus for blocking opponent's path
	score += _evaluate_blocking(white_player, black_player, game_logic)
	score -= _evaluate_blocking(black_player, white_player, game_logic)
	
	return score

func _evaluate_blocking(current_player: GameLogic.Player, opponent_player: GameLogic.Player, game_logic: GameLogic) -> float:
	var blocking_score := 0.0
	
	# Check if our pieces are blocking opponent's path
	for our_progress in current_player.pieces_progress:
		var our_position := current_player.path[our_progress]
		
		# Check if this position blocks any opponent pieces
		for opp_progress in opponent_player.pieces_progress:
			var opp_position := opponent_player.path[opp_progress]
			
			# If opponent piece is behind ours and we're blocking their path
			if opp_progress < our_progress and _is_blocking_path(our_position, opp_position, opponent_player.path):
				blocking_score += WEIGHT_BLOCKING_OPPONENT
	
	return blocking_score

func _is_blocking_path(blocker_pos: int, target_pos: int, path: Array[int]) -> bool:
	# Check if the blocker position is on the path between target and end
	var target_index := path.find(target_pos)
	var blocker_index := path.find(blocker_pos)
	
	if target_index == -1 or blocker_index == -1:
		return false
	
	# Check if blocker is ahead of target on the path
	return blocker_index > target_index

func _get_possible_die_rolls() -> Array[int]:
	# Based on the dice configuration in GameParameters
	match GameParameters.dice:
		GameTypes.DICE_D4x1:
			return [0, 1, 2, 3, 4]
		GameTypes.DICE_D3x2:
			return [0, 1, 2, 3]
		GameTypes.DICE_D2x3:
			return [0, 1, 2]
		GameTypes.DICE_D2x4:
			return [0, 1, 2]
		_:
			return [0, 1, 2, 3, 4] # Default fallback
