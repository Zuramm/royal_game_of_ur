extends Node3D

var white_positions: Array[Vector3] = [
	Vector3(0, 0, 1),
	Vector3(-1, 0, 1),
	Vector3(-2, 0, 1),
	Vector3(-3, 0, 1),
	Vector3(-4, 0, 1),
	Vector3(-4, 0, 0),
	Vector3(-3, 0, 0),
	Vector3(-2, 0, 0),
	Vector3(-1, 0, 0),
	Vector3(0, 0, 0),
	Vector3(1, 0, 0),
	Vector3(2, 0, 0),
	Vector3(3, 0, 0),
	Vector3(3, 0, 1),
	Vector3(2, 0, 1),
	Vector3(1, 0, 1),
]

var black_positions: Array[Vector3] = [
	Vector3(0, 0, -1),
	Vector3(-1, 0, -1),
	Vector3(-2, 0, -1),
	Vector3(-3, 0, -1),
	Vector3(-4, 0, -1),
	Vector3(-4, 0, 0),
	Vector3(-3, 0, 0),
	Vector3(-2, 0, 0),
	Vector3(-1, 0, 0),
	Vector3(0, 0, 0),
	Vector3(1, 0, 0),
	Vector3(2, 0, 0),
	Vector3(3, 0, 0),
	Vector3(3, 0, -1),
	Vector3(2, 0, -1),
	Vector3(1, 0, -1),
]

var positions: Array[Array] = [
	white_positions,
	black_positions,
]

var current_positions: Array[Vector3] :
	get:
		return positions[game_logic._current_player_color]

@export var game_logic: GameLogic
@export var white_piece: PackedScene
@export var black_piece: PackedScene
@export var pieces: int = 7

@export var board_shape: Shape3D
@export var board_offset: Vector3
@export var left_shape: Shape3D
@export var left_position: Vector3

var wpl: Array[Node3D] = []
var bpl: Array[Node3D] = []
var wpob: Array[Node3D] = []
var bpob: Array[Node3D] = []
var wps: Array[Node3D] = []
var bps: Array[Node3D] = []

var pieces_left: Array[Array] = [wpl, bpl]
var pieces_on_board: Array[Array] = [wpob, bpob]
var pieces_safe: Array[Array] = [wps, bps]

var current_pieces_left: Array[Node3D] :
	get:
		return pieces_left[game_logic._current_player_color]

var opponent_pieces_left: Array[Node3D] :
	get:
		return pieces_left[1 - game_logic._current_player_color]

var current_pieces_on_board: Array[Node3D] :
	get:
		return pieces_on_board[game_logic._current_player_color]

var opponent_pieces_on_board: Array[Node3D] :
	get:
		return pieces_on_board[1 - game_logic._current_player_color]

var current_pieces_safe: Array[Node3D] :
	get:
		return pieces_safe[game_logic._current_player_color]


var moves: Node

func _ready():
	pieces_on_board[GameLogic.PlayerColor.white].resize(14)
	pieces_on_board[GameLogic.PlayerColor.black].resize(14)
	
	for i in range(pieces):
		var node = white_piece.instantiate()
		pieces_left[GameLogic.PlayerColor.white].append(node)
		add_child(node)
		node = black_piece.instantiate()
		pieces_left[GameLogic.PlayerColor.black].append(node)
		add_child(node)
	
	reset()


func reset():
	for color in [GameLogic.PlayerColor.white, GameLogic.PlayerColor.black]:
		for i in range(14):
			var piece = pieces_on_board[color][i]
			if piece != null:
				pieces_left[color].append(piece)
				pieces_on_board[color][i] = null
		pieces_left[color].append_array(pieces_safe[color])
		pieces_safe[color].clear()
	
		for i in range(pieces):
			var node = pieces_left[color][i]
			node.position = (left_position + Vector3(0, i, 0)) * Vector3(1, 1, color * -2.0 + 1.0)
			node = black_piece.instantiate()
	
	$InGame.visible = true
	$GameOver.visible = false
	$GameOver.mouse_filter = Control.MOUSE_FILTER_IGNORE
	randomize()
	game_logic.start()
	roll_die()
	show_moves()


var current_color_name: String :
	get:
		match game_logic._current_player_color:
			GameLogic.PlayerColor.white:
				return "white"
			GameLogic.PlayerColor.black:
				return "black"
			_:
				return "unkown"


func roll_die():
	# todo: make this interactive
	var die = randi_range(1, 4)
	game_logic.roll_die(die)
	%RollLabel.text = "%s rolled %s" % [current_color_name, die]


func show_moves():
	if moves != null:
		remove_child(moves)
	
	moves = Node3D.new()
	add_child(moves)
	
	for move in game_logic.moves:
		var node = preload("res://board_move.tscn").instantiate()
		node.positions = current_positions
		if move is GameLogic.MoveOntoBoard:
			node.start_position = 0
			node.end_position = move.to_space + 1
		elif move is GameLogic.MoveOnBoard:
			node.start_position = move.piece + 1
			node.end_position = move.to_space + 1
			node.does_kill = move.does_kill
		elif move is GameLogic.MoveFromBoard:
			node.start_position = move.piece + 1
			node.end_position = len(current_positions) - 1
		node.board_shape = board_shape
		node.board_offset = board_offset
		node.left_shape = left_shape
		node.left_position = left_position * Vector3(1, 1, game_logic.current_player.color * -2.0 + 1.0)
		node.selected.connect(_on_move_selected.bind(move))
		moves.add_child(node)
	
	if game_logic.moves.is_empty():
		game_logic.apply_move(null)
		roll_die()
		show_moves()


func _on_move_selected(move: GameLogic.Move):
	if move is GameLogic.MoveOntoBoard:
		var piece = current_pieces_left.pop_back()
		piece.position = current_positions[move.to_space + 1]
		current_pieces_on_board[move.to_space] = piece
	elif move is GameLogic.MoveOnBoard:
		var piece = current_pieces_on_board[move.piece]
		current_pieces_on_board[move.piece] = null
		if move.does_kill:
			var opponent_piece = opponent_pieces_on_board[move.to_space]
			opponent_pieces_on_board[move.to_space] = null
			opponent_piece.position = (left_position + Vector3(0, 2, 0)) * Vector3(1, 1, game_logic.current_player.color * 2 - 1)
			opponent_pieces_left.append(opponent_piece)
		piece.position = current_positions[move.to_space + 1]
		current_pieces_on_board[move.to_space] = piece
	elif move is GameLogic.MoveFromBoard:
		var piece = current_pieces_on_board[move.piece]
		current_pieces_on_board[move.piece] = null
		piece.position = left_position * Vector3(-1, 1, game_logic.current_player.color * -2.0 + 1.0) + Vector3(0, 2, 0)
		current_pieces_safe.append(piece)
	
	game_logic.apply_move(move)
	
	roll_die()
	show_moves()


func _on_game_logic_game_ended(player):
	$InGame.visible = false
	$GameOver.visible = true
	$GameOver.mouse_filter = Control.MOUSE_FILTER_STOP
	match player.color:
		GameLogic.PlayerColor.white:
			%WinnerLabel.text = "White won"
		GameLogic.PlayerColor.black:
			%WinnerLabel.text = "Black won"


func _on_button_pressed():
	reset()

