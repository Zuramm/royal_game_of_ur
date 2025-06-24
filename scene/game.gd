extends Node3D


#  0  1  2  3        4  5
#  6  7  8  9 10 11 12 13
# 14 15 16 17       18 19

const BOARD_POSITIONS: Array[Vector3] = [
	Vector3(-4, 0, 1),
	Vector3(-3, 0, 1),
	Vector3(-2, 0, 1),
	Vector3(-1, 0, 1),
	Vector3(2, 0, 1),
	Vector3(3, 0, 1),
	Vector3(-4, 0, 0),
	Vector3(-3, 0, 0),
	Vector3(-2, 0, 0),
	Vector3(-1, 0, 0),
	Vector3(0, 0, 0),
	Vector3(1, 0, 0),
	Vector3(2, 0, 0),
	Vector3(3, 0, 0),
	Vector3(-4, 0, -1),
	Vector3(-3, 0, -1),
	Vector3(-2, 0, -1),
	Vector3(-1, 0, -1),
	Vector3(2, 0, -1),
	Vector3(3, 0, -1),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1),
	Vector3(0, 0, -1),
	Vector3(1, 0, -1),
]

func map_positions(positions1: Array[int]) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for position1 in positions1:
		result.append(BOARD_POSITIONS[position1])
	return result


const WHITE_START_POSITION := BOARD_POSITIONS[20]
const WHITE_END_POSITION := BOARD_POSITIONS[21]
const BLACK_START_POSITION := BOARD_POSITIONS[22]
const BLACK_END_POSITION := BOARD_POSITIONS[23]

var current_start_position: Vector3:
	get:
		match game_logic._current_player_color:
			GameLogic.PlayerColor.white:
				return WHITE_START_POSITION
			GameLogic.PlayerColor.black:
				return BLACK_START_POSITION
			var color:
				push_error("Unknown current player color: ", color)
				return Vector3.ZERO

var current_end_position: Vector3:
	get:
		match game_logic._current_player_color:
			GameLogic.PlayerColor.white:
				return WHITE_END_POSITION
			GameLogic.PlayerColor.black:
				return BLACK_END_POSITION
			var color:
				push_error("Unknown current player color: ", color)
				return Vector3.ZERO


@export var game_logic: GameLogic
@export var white_piece: PackedScene
@export var black_piece: PackedScene
@export var pieces: int = 7

@export var board_shape: BoxShape3D
@export var board_offset: Vector3
@export var left_shape: BoxShape3D
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

var current_pieces_left: Array[Node3D]:
	get:
		return pieces_left[game_logic._current_player_color]

var opponent_pieces_left: Array[Node3D]:
	get:
		return pieces_left[1 - game_logic._current_player_color]

var current_pieces_on_board: Array[Node3D]:
	get:
		return pieces_on_board[game_logic._current_player_color]

var opponent_pieces_on_board: Array[Node3D]:
	get:
		return pieces_on_board[1 - game_logic._current_player_color]

var current_pieces_safe: Array[Node3D]:
	get:
		return pieces_safe[game_logic._current_player_color]


var moves: Node


@onready var _in_game_node := $InGame as Control
@onready var _game_over_node := $GameOver as Control
@onready var _winner_label_node := %WinnerLabel as Label
@onready var _roll_label_node := %RollLabel as Label


func _ready() -> void:
	var result: int
	result = pieces_on_board[GameLogic.PlayerColor.white].resize(BOARD_POSITIONS.size())
	if result != OK:
		push_error("Failed to resize white pieces on board: ", error_string(result))
	result = pieces_on_board[GameLogic.PlayerColor.black].resize(BOARD_POSITIONS.size())
	if result != OK:
		push_error("Failed to resize white pieces on board: ", error_string(result))
	
	for i in range(pieces):
		var node := white_piece.instantiate()
		pieces_left[GameLogic.PlayerColor.white].append(node)
		add_child(node)
		node = black_piece.instantiate()
		pieces_left[GameLogic.PlayerColor.black].append(node)
		add_child(node)
	
	reset()


func _random_dir() -> Vector3:
	while true:
		var vec := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		if vec.length_squared() < 1.0:
			return vec
	return Vector3.ZERO

const PIECE_SIZE = 0.6

func reset() -> void:
	for color in GameLogic.PlayerColor.values() as Array[GameLogic.PlayerColor]:
		for i in range(14):
			var piece: Node3D = pieces_on_board[color][i]
			if piece != null:
				pieces_left[color].append(piece)
				pieces_on_board[color][i] = null
		pieces_left[color].append_array(pieces_safe[color])
		pieces_safe[color].clear()
	
		for i in range(pieces):
			var x := i % 5
			var y := i / 5
			var node: Node3D = pieces_left[color][i]
			node.position = (left_position + Vector3(x - 2, 0, y - 0.5) * PIECE_SIZE) * Vector3(1, 1, color * -2.0 + 1.0)
			#node.linear_velocity = _random_dir() * 2.0
			node = black_piece.instantiate() as Node3D
	
	_in_game_node.visible = true
	_game_over_node.visible = false
	_game_over_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	randomize()
	game_logic.start()
	roll_die()
	show_moves()


var current_color_name: String:
	get:
		match game_logic._current_player_color:
			GameLogic.PlayerColor.white:
				return "white"
			GameLogic.PlayerColor.black:
				return "black"
			_:
				return "unkown"


func roll_die() -> void:
	# todo: make this interactive
	var die := randi_range(0, 1) + randi_range(0, 1) + randi_range(0, 1)
	if die == 0:
		die = 4
	game_logic.roll_die(die)
	_roll_label_node.text = "%s rolled %s" % [current_color_name, die]


func show_moves() -> void:
	if moves != null:
		remove_child(moves)
	
	moves = Node3D.new()
	add_child(moves)

	for move in game_logic.moves:
		var node := preload("res://entity/board_move.tscn").instantiate() as BoardMove
		if move is GameLogic.MoveOntoBoard:
			var move_onto := move as GameLogic.MoveOntoBoard
			node.positions = map_positions(move_onto.path_positions)
			node.positions.push_front(current_start_position)
			node.collision_shape = left_shape
			node.collision_position = left_position * Vector3(1, 1, game_logic.current_player.color * -2.0 + 1.0)
		elif move is GameLogic.MoveOnBoard:
			var move_on := move as GameLogic.MoveOnBoard
			node.positions = map_positions(move_on.path_positions)
			node.collision_shape = board_shape
			node.collision_position = node.positions[0]
			node.does_kill = move_on.does_kill
		elif move is GameLogic.MoveFromBoard:
			var move_from := move as GameLogic.MoveFromBoard
			node.positions = map_positions(move_from.path_positions)
			node.positions.push_back(current_end_position)
			node.collision_shape = board_shape
			node.collision_position = node.positions[0]
		var result := node.selected.connect(_on_move_selected.bind(move))
		if result != OK:
			push_error(error_string(result))
		moves.add_child(node)
	
	if game_logic.moves.is_empty():
		game_logic.apply_move(null)
		roll_die()
		show_moves()


func _on_move_selected(move: GameLogic.Move) -> void:
	if move is GameLogic.MoveOntoBoard:
		var move_onto := move as GameLogic.MoveOntoBoard
		print("chose move onto board: -> ", move_onto.target_position)
		var target_position := BOARD_POSITIONS[move_onto.target_position]
		var piece: Node3D = current_pieces_left.pop_back()
		if piece is RigidBody3D:
			var rigid_body: RigidBody3D = piece
			rigid_body.linear_velocity = calculate_launch_velocity(rigid_body.position, target_position, 2.0)
		else:
			piece.position = target_position
		current_pieces_on_board[move_onto.target_position] = piece
	elif move is GameLogic.MoveOnBoard:
		var move_on := move as GameLogic.MoveOnBoard
		print("chose move on board:", move_on.piece_position, " -> ", move_on.target_position)
		var target_position := BOARD_POSITIONS[move_on.target_position]
		var piece := current_pieces_on_board[move_on.piece_position] as RigidBody3D
		current_pieces_on_board[move_on.piece_position] = null
		if move_on.does_kill:
			var opponent_piece := opponent_pieces_on_board[move_on.target_position]
			opponent_pieces_on_board[move_on.target_position] = null
			if opponent_piece is RigidBody3D:
				var rigid_body := opponent_piece as RigidBody3D
				rigid_body.linear_velocity = calculate_launch_velocity(rigid_body.position, (left_position + Vector3(0, 2, 0)) * Vector3(1, 1, game_logic.current_player.color * 2 - 1))
			else:
				opponent_piece.position = (left_position + Vector3(0, 2, 0)) * Vector3(1, 1, game_logic.current_player.color * 2 - 1)
			opponent_pieces_left.append(opponent_piece)
		if piece is RigidBody3D:
			var rigid_body := piece as RigidBody3D
			rigid_body.linear_velocity = calculate_launch_velocity(piece.position, target_position)
		else:
			piece.position = target_position
		current_pieces_on_board[move_on.target_position] = piece
	elif move is GameLogic.MoveFromBoard:
		var move_from := move as GameLogic.MoveFromBoard
		print("chose move from board:", move_from.piece_position, " -> ")
		var target_position := left_position * Vector3(-1, 1, game_logic.current_player.color * -2.0 + 1.0) + Vector3(0, 2, 0)
		var piece := current_pieces_on_board[move_from.piece_position] as RigidBody3D
		current_pieces_on_board[move_from.piece_position] = null
		if piece is RigidBody3D:
			var rigid_body := piece as RigidBody3D
			rigid_body.linear_velocity = calculate_launch_velocity(rigid_body.position, target_position)
		else:
			piece.position = left_position * Vector3(-1, 1, game_logic.current_player.color * -2.0 + 1.0) + Vector3(0, 2, 0)
		current_pieces_safe.append(piece)
	
	game_logic.apply_move(move)
	
	roll_die()
	show_moves()


func calculate_launch_velocity(start_position: Vector3, target_position: Vector3, arc_height: float = 1.0) -> Vector3:
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	# Calculate the horizontal distance
	var horizontal_distance := Vector2(target_position.x - start_position.x, target_position.z - start_position.z).length()

	# Calculate the vertical displacement
	# var 3 := target_position.y - start_position.y

	# Calculate time of flight using the quadratic formula
	# We want to solve: y = v_y * t - 0.5 * g * t^2
	# Where y is vertical_displacement, v_y is initial vertical velocity, g is gravity, t is time

	# For a nice arc, we'll aim to reach a peak height above both the start and target positions
	var max_height := maxf(start_position.y, target_position.y) + arc_height
	var h1 := max_height - start_position.y
	var h2 := max_height - target_position.y

	# Time to reach peak from start
	var t1 := sqrt(2 * h1 / gravity)

	# Time to reach target from peak
	var t2 := sqrt(2 * h2 / gravity)

	# Total flight time
	var flight_time := t1 + t2

	# Calculate horizontal velocity
	var horizontal_velocity := horizontal_distance / flight_time

	# Calculate the horizontal direction
	var horizontal_direction := Vector2(
		target_position.x - start_position.x,
		target_position.z - start_position.z
	).normalized()

	# Calculate initial vertical velocity
	var vertical_velocity := gravity * t1

	# Construct the final velocity vector
	var velocity := Vector3(
		horizontal_direction.x * horizontal_velocity,
		vertical_velocity,
		horizontal_direction.y * horizontal_velocity
	)

	return velocity


func _on_game_logic_game_ended(player: GameLogic.Player) -> void:
	_in_game_node.visible = false
	_game_over_node.visible = true
	_game_over_node.mouse_filter = Control.MOUSE_FILTER_STOP
	match player.color:
		GameLogic.PlayerColor.white:
			_winner_label_node.text = "White won"
		GameLogic.PlayerColor.black:
			_winner_label_node.text = "Black won"


func _on_button_pressed() -> void:
	reset()
