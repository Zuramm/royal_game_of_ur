class_name GameLogic
extends Node


enum PlayerColor {
	white,
	black,
}


class Player:
	var color: PlayerColor
	var pieces_left: int
	var pieces_board: Array[int] = []
	var pieces_safe: int = 0
	
	func _init(color_: PlayerColor, pieces: int):
		color = color_
		pieces_left = pieces
	
	func debug():
		match color:
			PlayerColor.white:
				print("Team white")
			PlayerColor.black:
				print("Team black")
		
		var board: Array[int] = []
		board.resize(14)
		for pos in pieces_board:
			board[pos] = 1
		print("Board: %s" % "".join(board))
		print("Pieces left: %s" % pieces_left)
		print("Pieces safe: %s" % pieces_safe)


class Move:
	func apply(_current_player: Player, _opponent_player: Player):
		pass


class MoveOntoBoard extends Move:
	var to_space: int
	
	func _init(to_space_: int):
		to_space = to_space_
	
	func apply(current_player: Player, _opponent_player: Player):
		current_player.pieces_left -= 1
		current_player.pieces_board.append(to_space)


class MoveOnBoard extends Move:
	var piece: int
	var to_space: int
	var does_kill: bool
	
	func _init(piece_: int, to_space_: int, does_kill_: bool):
		piece = piece_
		to_space = to_space_
		does_kill = does_kill_
	
	func apply(current_player: Player, opponent_player: Player):
		var i = current_player.pieces_board.find(piece)
		current_player.pieces_board[i] = to_space
		if does_kill:
			i = opponent_player.pieces_board.find(to_space)
			opponent_player.pieces_board.remove_at(i)
			opponent_player.pieces_left += 1


class MoveFromBoard extends Move:
	var piece: int
	
	func _init(piece_: int):
		piece = piece_
	
	func apply(current_player: Player, _opponent_player: Player):
		var i = current_player.pieces_board.find(piece)
		current_player.pieces_board.remove_at(i)
		current_player.pieces_safe += 1


signal piece_moved(Move)
signal game_ended(Player)

@export var route_length: int = 14
@export var common_route_start: int = 4
@export var common_route_end: int = 12
@export var pieces: int = 7

var moves: Array[Move]

var _white_player: Player
var _black_player: Player

var _current_player_color: PlayerColor

var current_player: Player :
	get:
		match _current_player_color:
			PlayerColor.white:
				return _white_player
			PlayerColor.black:
				return _black_player
			_:
				return null

var opponent_player: Player :
	get:
		match _current_player_color:
			PlayerColor.white:
				return _black_player
			PlayerColor.black:
				return _white_player
			_:
				return null


func start():
	moves = []
	
	_white_player = Player.new(PlayerColor.white, pieces)
	_black_player = Player.new(PlayerColor.black, pieces)
	
	_current_player_color = PlayerColor.white


func roll_die(die: int):
	moves = []
	
	if current_player.pieces_left > 0 and not current_player.pieces_board.has(die - 1):
		moves.append(MoveOntoBoard.new(die - 1))
	
	for piece in current_player.pieces_board:
		var new_space = piece + die
		print("move from %s to %s" % [piece, new_space])
		if new_space > route_length:
			pass
		elif new_space == route_length:
			moves.append(MoveFromBoard.new(piece))
		elif not current_player.pieces_board.has(new_space):
			var does_kill = common_route_start <= new_space \
			and new_space < common_route_end \
			and opponent_player.pieces_board.has(new_space)
			
			moves.append(MoveOnBoard.new(piece, new_space, does_kill))
	
	current_player.debug()


func apply_move(move: Move):
	if move != null:
		move.apply(current_player, opponent_player)
		piece_moved.emit(move)
		if current_player.pieces_left == 0 and current_player.pieces_board.is_empty():
			game_ended.emit(current_player)
	
	_current_player_color = 1 - _current_player_color

