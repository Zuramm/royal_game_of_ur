class_name Player3D
extends Node3D


var _start_pieces: Array[Node3D] = []
var _board_pieces: Array[Node3D] = []
var _end_pieces: Array[Node3D] = []


func _compute_piece_start_position(index: int) -> Vector3:
	var x_offset := roundf(GameParameters.pieces / 4.0)
	var y_offset := 3.0 / 4.0 if GameParameters.pieces > 1 else 0.0
	var y: float = (index % 2) * 3 / 2
	var x: float = index / 2 + y / 2
	return Vector3(x - x_offset, 0, y - y_offset)


func _compute_piece_end_position(index: int) -> Vector3:
	return Vector3(0, index, 0)


@export var piece_scene: PackedScene
@export var start_transform: Transform3D = Transform3D.IDENTITY:
	set(value):
		start_transform = value
		for i in range(_start_pieces.size()):
			_start_pieces[i].position = start_transform * _compute_piece_start_position(i)
@export var board_transform: Transform3D = Transform3D.IDENTITY:
	set(value):
		board_transform = value
		for i in range(_board_pieces.size()):
			_board_pieces[i].position = board_transform * GameParameters.board_positions[i]
@export var end_transform: Transform3D = Transform3D.IDENTITY:
	set(value):
		end_transform = value
		for i in range(_end_pieces.size()):
			_end_pieces[i].position = end_transform * _compute_piece_end_position(i)


func setup() -> void:
	var result: int

	for i in range(_board_pieces.size()):
		if _board_pieces[i] != null:
			_start_pieces.push_back(_board_pieces[i])
			_board_pieces[i] = null
	
	for i in range(_end_pieces.size()):
		_start_pieces.push_back(_end_pieces.pop_back())
	
	for i in range(_start_pieces.size(), GameParameters.pieces):
		var node := piece_scene.instantiate() as Node3D
		_start_pieces.append(node)
		add_child(node)
	
	for i in range(GameParameters.pieces, _start_pieces.size()):
		var piece: Node3D = _start_pieces.pop_back()
		piece.queue_free()
	
	for i in range(GameParameters.pieces):
		_start_pieces[i].position = start_transform * _compute_piece_start_position(i)

	result = _board_pieces.resize(GameParameters.board_positions.size())
	if result != OK:
		push_error("Failed to resize board pieces: ", error_string(result))


func turn(moves: Array[GameLogic.Move], opponent: Player3D) -> GameLogic.Move:
	var move: GameLogic.Move = await _pick_move(moves)
	if move is GameLogic.MoveOntoBoard:
		var move_onto := move as GameLogic.MoveOntoBoard
		var node: Node3D = _start_pieces.pop_back()
		_board_pieces[move_onto.target_position] = node
		if move_onto.does_kill:
			opponent.kill_piece(move_onto.target_position)
		print("Moving piece onto board: ", move_onto.target_position)
		await _move_piece(node, GameParameters.board_positions[move_onto.target_position])
	elif move is GameLogic.MoveOnBoard:
		var move_on := move as GameLogic.MoveOnBoard
		var node := _board_pieces[move_on.piece_position]
		_board_pieces[move_on.piece_position] = null
		_board_pieces[move_on.target_position] = node
		if move_on.does_kill:
			opponent.kill_piece(move_on.target_position)
		print("Board pieces: ", _board_pieces)
		print("Moving piece on board: ", move_on.piece_position, " to ", move_on.target_position)
		await _move_piece(node, GameParameters.board_positions[move_on.target_position])
	elif move is GameLogic.MoveFromBoard:
		var move_from := move as GameLogic.MoveFromBoard
		var node := _board_pieces[move_from.piece_position]
		_board_pieces[move_from.piece_position] = null
		_end_pieces.push_back(node)
		print("Board pieces: ", _board_pieces)
		print("Moving piece from board: ", move_from.piece_position, " to ", _end_pieces.size() - 1)
		await _move_piece(node, end_transform * _compute_piece_end_position(_end_pieces.size() - 1))
	elif move == null:
		await get_tree().create_timer(0.1).timeout
	else:
		push_error("Invalid move: ", move)
	return move


func _move_piece(piece: Node3D, to: Vector3) -> void:
	await get_tree().create_timer(0.1).timeout
	piece.position = to


func _pick_move(moves: Array[GameLogic.Move]) -> GameLogic.Move:
	await get_tree().create_timer(0.1).timeout
	return moves[0]


func kill_piece(piece_position: int) -> void:
	var node := _board_pieces[piece_position]
	if node == null:
		push_error("No piece at position: ", piece_position)
		return
	_board_pieces[piece_position] = null
	_start_pieces.push_back(node)
	print("Killing piece: ", piece_position, " to ", _start_pieces.size() - 1)
	await _move_piece(node, start_transform * _compute_piece_start_position(_start_pieces.size() - 1))
