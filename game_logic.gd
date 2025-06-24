class_name GameLogic
extends Node


enum PlayerColor {
	white,
	black,
}


class Player:
	var color: PlayerColor
	var pieces_left: int
	var pieces_progress: Array[int] = []
	var pieces_safe: int = 0
	var path: Array[int]
	
	func _init(color_: PlayerColor, pieces: int) -> void:
		color = color_
		pieces_left = pieces

	# Returns the index of pieces_progress of the piece at the given position, or -1 if no piece is at the position
	func get_piece_at(position: int) -> int:
		for i in range(pieces_progress.size()):
			if path[pieces_progress[i]] == position:
				return i
		return -1
	
	func debug() -> void:
		match color:
			PlayerColor.white:
				print("Team white")
			PlayerColor.black:
				print("Team black")
		
		print("Progress: %s" % ", ".join(pieces_progress))
		print("Pieces left: %s" % pieces_left)
		print("Pieces safe: %s" % pieces_safe)


class Move:
	func apply(_current_player: Player, _opponent_player: Player) -> void:
		pass


class MoveOntoBoard extends Move:
	var _target_progress: int
	var target_position: int
	var path_positions: Array[int]
	
	func _init(player: Player, target_progress: int) -> void:
		_target_progress = target_progress
		target_position = player.path[target_progress]
		path_positions = []
		for i in range(_target_progress + 1):
			path_positions.append(player.path[i])
	
	func apply(current_player: Player, _opponent_player: Player) -> void:
		current_player.pieces_left -= 1
		current_player.pieces_progress.append(_target_progress)


class MoveOnBoard extends Move:
	var _piece_progress: int
	var _target_progress: int
	var _opponent_progress: int
	var piece_position: int
	var target_position: int
	var does_kill: bool
	var path_positions: Array[int]

	func _init(player: Player, piece_progress: int, target_progress: int, opponent_progress: int = -1) -> void:
		_piece_progress = piece_progress
		_target_progress = target_progress
		piece_position = player.path[piece_progress]
		target_position = player.path[target_progress]
		_opponent_progress = opponent_progress
		does_kill = _opponent_progress != -1
		path_positions = []
		for i in range(_piece_progress, _target_progress + 1):
			path_positions.append(player.path[i])

	func apply(current_player: Player, opponent_player: Player) -> void:
		var i := current_player.pieces_progress.find(_piece_progress)
		current_player.pieces_progress[i] = _target_progress
		if does_kill:
			var j := opponent_player.pieces_progress.find(_opponent_progress)
			opponent_player.pieces_progress.remove_at(j)
			opponent_player.pieces_left += 1


class MoveFromBoard extends Move:
	var _piece_progress: int
	var piece_position: int
	var path_positions: Array[int]

	func _init(player: Player, piece_progress: int) -> void:
		_piece_progress = piece_progress
		piece_position = player.path[piece_progress]
		path_positions = []
		for i in range(_piece_progress, player.path.size()):
			path_positions.append(player.path[i])

	func apply(current_player: Player, _opponent_player: Player) -> void:
		var i := current_player.pieces_progress.find(_piece_progress)
		current_player.pieces_progress.remove_at(i)
		current_player.pieces_safe += 1


signal piece_moved(move: Move)
signal game_ended(player: Player)

#  0  1  2  3        4  5
#  6  7  8  9 10 11 12 13
# 14 15 16 17       18 19

var rosettes: Array[int] = [0, 4, 9, 14, 18]

@onready var white_path: Array[int] = GameParameters.white_path
@onready var black_path: Array[int] = GameParameters.black_path

@onready var pieces: int = GameParameters.pieces

var moves: Array[Move]

var _white_player: Player
var _black_player: Player

var _current_player_color: PlayerColor

var current_player: Player:
	get:
		match _current_player_color:
			PlayerColor.white:
				return _white_player
			PlayerColor.black:
				return _black_player
			_:
				return null

var opponent_player: Player:
	get:
		match _current_player_color:
			PlayerColor.white:
				return _black_player
			PlayerColor.black:
				return _white_player
			_:
				return null


func start() -> void:
	moves = []
	
	_white_player = Player.new(PlayerColor.white, pieces)
	_black_player = Player.new(PlayerColor.black, pieces)
	
	_white_player.path = white_path
	_black_player.path = black_path
	
	_current_player_color = PlayerColor.white


func roll_die(die: int) -> void:
	moves = []

	if current_player.pieces_left > 0 and not current_player.pieces_progress.has(die - 1):
		moves.append(MoveOntoBoard.new(current_player, die - 1))

	for piece_progress in current_player.pieces_progress:
		var target_progress := piece_progress + die
		var target_position := current_player.path[clampi(target_progress, 0, current_player.path.size() - 1)]
		print("move from progress %s to %s" % [piece_progress, target_progress])

		if target_progress == current_player.path.size():
			moves.append(MoveFromBoard.new(current_player, piece_progress))
		elif target_progress > current_player.path.size():
			pass
		elif current_player.get_piece_at(target_position) == -1:
			var is_safe := GameParameters.rosette_safe and target_position in rosettes
			var opponent_index := opponent_player.get_piece_at(target_position)
			var opponent_progress := opponent_player.pieces_progress[opponent_index] if opponent_index != -1 else -1

			if not is_safe or opponent_progress == -1:
				moves.append(MoveOnBoard.new(current_player, piece_progress, target_progress, opponent_progress))

	current_player.debug()


func apply_move(move: Move) -> void:
	if move != null:
		move.apply(current_player, opponent_player)
		piece_moved.emit(move)
		if current_player.pieces_left == 0 and current_player.pieces_progress.is_empty():
			game_ended.emit(current_player)
	
	_current_player_color = (1 - _current_player_color as int) as PlayerColor
