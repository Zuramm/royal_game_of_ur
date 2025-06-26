extends Node3D


@export var game_logic: GameLogic
@export var white_piece: PackedScene
@export var black_piece: PackedScene


@export var board_shape: BoxShape3D
@export var board_offset: Vector3
@export var left_shape: BoxShape3D
@export var left_position: Vector3
@export var white_start_transform: Node3D
@export var white_board_transform: Node3D
@export var white_end_transform: Node3D
@export var black_start_transform: Node3D
@export var black_board_transform: Node3D
@export var black_end_transform: Node3D


var white_player: Player3D
var black_player: Player3D


@onready var _in_game_node := $InGame as Control
@onready var _game_over_node := $GameOver as Control
@onready var _winner_label_node := %WinnerLabel as Label
@onready var _roll_label_node := %RollLabel as Label


func _ready() -> void:
	var player := Player3DHuman.new()
	player.piece_scene = white_piece
	player.start_transform = white_start_transform.transform
	player.board_transform = white_board_transform.transform
	player.end_transform = white_end_transform.transform
	player.start_collision_shape = left_shape
	player.board_collision_shape = board_shape
	white_player = player
	add_child(white_player)
	black_player = Player3DAIFast.new()
	black_player.piece_scene = black_piece
	black_player.start_transform = black_start_transform.transform
	black_player.board_transform = black_board_transform.transform
	black_player.end_transform = black_end_transform.transform
	add_child(black_player)

	reset()


const PIECE_SIZE = 0.6

func reset() -> void:
	_in_game_node.visible = true
	_game_over_node.visible = false
	_game_over_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_logic.start()
	if white_player is Player3DHuman:
		var human_player := white_player as Player3DHuman
		human_player.path_start_position = GameParameters.white_start_position
		human_player.path_end_position = GameParameters.white_end_position
	if black_player is Player3DHuman:
		var human_player := black_player as Player3DHuman
		human_player.path_start_position = GameParameters.black_start_position
		human_player.path_end_position = GameParameters.black_end_position
	white_player.setup()
	black_player.setup()
	game_loop()


func game_loop() -> void:
	while not game_logic.is_game_over:
		var player: Player3D
		var opponent: Player3D
		match game_logic.current_player.color:
			GameLogic.PlayerColor.white:
				player = white_player
				opponent = black_player
			GameLogic.PlayerColor.black:
				player = black_player
				opponent = white_player
			_:
				push_error("Unknown player color: ", game_logic.current_player.color)
				player = null
		roll_die()
		var move := await player.turn(game_logic.moves, opponent)
		game_logic.apply_move(move)


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
	var die: int
	match GameParameters.dice:
		GameTypes.DICE_D4x1:
			die = randi_range(1, 4)
		GameTypes.DICE_D3x2:
			die = randi_range(0, 2) + randi_range(0, 2)
		GameTypes.DICE_D2x3:
			die = randi_range(0, 1) + randi_range(0, 1) + randi_range(0, 1)
			if die == 0:
				die = 4
		GameTypes.DICE_D2x4:
			die = randi_range(0, 1) + randi_range(0, 1) + randi_range(0, 1) + randi_range(0, 1)
	game_logic.roll_die(die)
	_roll_label_node.text = "%s rolled %s" % [current_color_name, die]
	_roll_label_node.label_settings.font_color = Color.WHITE if die > 0 else Color.SALMON


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
