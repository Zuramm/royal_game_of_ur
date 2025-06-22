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
	
	func debug() -> void:
		match color:
			PlayerColor.white:
				print("Team white")
			PlayerColor.black:
				print("Team black")
		
		print("Progress: %s" % pieces_progress)
		print("Pieces left: %s" % pieces_left)
		print("Pieces safe: %s" % pieces_safe)


class Move:
	func apply(_current_player: Player, _opponent_player: Player) -> void:
		pass


class MoveOntoBoard extends Move:
	var to_space: int
	
	func _init(to_space_: int) -> void:
		to_space = to_space_
	
	func apply(current_player: Player, _opponent_player: Player) -> void:
		current_player.pieces_left -= 1
		current_player.pieces_progress.append(to_space)


class MoveOnBoard extends Move:
	var piece_progress: int
	var new_progress: int
	var does_kill: bool
	var opponent_piece_progress_to_kill: int
	
	func _init(piece_progress_: int, new_progress_: int, does_kill_: bool, opponent_piece_progress_to_kill_: int = -1) -> void:
		piece_progress = piece_progress_
		new_progress = new_progress_
		does_kill = does_kill_
		opponent_piece_progress_to_kill = opponent_piece_progress_to_kill_
	
	func apply(current_player: Player, opponent_player: Player) -> void:
		var i := current_player.pieces_progress.find(piece_progress)
		current_player.pieces_progress[i] = new_progress
		if does_kill:
			var j := opponent_player.pieces_progress.find(opponent_piece_progress_to_kill)
			opponent_player.pieces_progress.remove_at(j)
			opponent_player.pieces_left += 1


class MoveFromBoard extends Move:
	var piece_progress: int
	
	func _init(piece_: int) -> void:
		piece_progress = piece_
	
	func apply(current_player: Player, _opponent_player: Player) -> void:
		var i := current_player.pieces_progress.find(piece_progress)
		current_player.pieces_progress.remove_at(i)
		current_player.pieces_safe += 1


signal piece_moved(move: Move)
signal game_ended(player: Player)

#  0  1  2  3        4  5
#  6  7  8  9 10 11 12 13
# 14 15 16 17       18 19

@export var white_path: Array[int] = [3, 2, 1, 0, 6, 7, 8, 9, 10, 11, 12, 13, 5, 4]
@export var black_path: Array[int] = [17, 16, 15, 14, 6, 7, 8, 9, 10, 11, 12, 13, 19, 18]

@export var pieces: int = 7

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
		moves.append(MoveOntoBoard.new(die - 1))

	for piece_progress in current_player.pieces_progress:
		var new_progress := piece_progress + die
		print("move from progress %s to %s" % [piece_progress, new_progress])

		if new_progress == current_player.path.size():
			moves.append(MoveFromBoard.new(piece_progress))
		elif new_progress > current_player.path.size():
			pass
		elif not current_player.pieces_progress.has(new_progress):
			var does_kill := false
			var opponent_piece_progress_to_kill := -1

			var new_board_space := current_player.path[new_progress]

			for opp_piece_prog in opponent_player.pieces_progress:
				var opp_board_space := opponent_player.path[opp_piece_prog]
				if opp_board_space == new_board_space:
					does_kill = true
					opponent_piece_progress_to_kill = opp_piece_prog
					break

			moves.append(MoveOnBoard.new(piece_progress, new_progress, does_kill, opponent_piece_progress_to_kill))

	current_player.debug()


func apply_move(move: Move) -> void:
	if move != null:
		move.apply(current_player, opponent_player)
		piece_moved.emit(move)
		if current_player.pieces_left == 0 and current_player.pieces_progress.is_empty():
			game_ended.emit(current_player)
	
	_current_player_color = (1 - _current_player_color as int) as PlayerColor
