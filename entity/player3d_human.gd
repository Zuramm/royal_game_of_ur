class_name Player3DHuman
extends Player3D


signal _move_selected(move: GameLogic.Move)


var _moves_group: Node3D = null


@export var start_collision_shape: BoxShape3D
@export var board_collision_shape: BoxShape3D
@export var path_start_position: Vector3
@export var path_end_position: Vector3


func _pick_move(moves: Array[GameLogic.Move]) -> GameLogic.Move:
	if _moves_group != null:
		_moves_group.queue_free()
		_moves_group = null
	
	if moves.is_empty():
		return null
	
	_moves_group = Node3D.new()
	add_child(_moves_group)

	for move in moves:
		var node := preload("res://entity/board_move.tscn").instantiate() as BoardMove
		if move is GameLogic.MoveOntoBoard:
			var move_onto := move as GameLogic.MoveOntoBoard
			node.positions = GameParameters.map_positions(move_onto.path_positions)
			node.positions.push_front(path_start_position)
			node.collision_shape = start_collision_shape
			node.collision_position = start_transform * Vector3.ZERO
		elif move is GameLogic.MoveOnBoard:
			var move_on := move as GameLogic.MoveOnBoard
			node.positions = GameParameters.map_positions(move_on.path_positions)
			node.collision_shape = board_collision_shape
			node.collision_position = node.positions[0]
			node.does_kill = move_on.does_kill
		elif move is GameLogic.MoveFromBoard:
			var move_from := move as GameLogic.MoveFromBoard
			node.positions = GameParameters.map_positions(move_from.path_positions)
			node.positions.push_back(path_end_position)
			node.collision_shape = board_collision_shape
			node.collision_position = node.positions[0]
		var result := node.selected.connect(_on_move_selected.bind(move))
		if result != OK:
			push_error(error_string(result))
		_moves_group.add_child(node)
	return await _move_selected


func _on_move_selected(move: GameLogic.Move) -> void:
	if _moves_group != null:
		_moves_group.queue_free()
		_moves_group = null
	_move_selected.emit(move)
