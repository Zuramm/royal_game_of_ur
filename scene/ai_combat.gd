extends Control


const RUNS = 100
const AI_NAMES: Array[String] = [
	"Naive",
	"Fast",
	"Smart",
	"Cursor",
]
var AI_CLASSES: Array[AI] = [
	AINaive.new(),
	AIFast.new(),
	AISmart.new(),
	AICursor.new(),
]


var mutex: Mutex
var thread: Thread


@onready var results_table: GridContainer = %Results
@onready var result_time: Label = %ResultTime


func _ready() -> void:
	var err: int

	results_table.columns = AI_NAMES.size() + 1

	var table_corner := Label.new()
	table_corner.text = "W\\B"
	results_table.add_child(table_corner)

	var label: Label

	for ai_name in AI_NAMES:
		label = Label.new()
		label.text = ai_name
		results_table.add_child(label)

	for white_name in AI_NAMES:
		label = Label.new()
		label.text = white_name
		results_table.add_child(label)

		for black_name in AI_NAMES:
			label = Label.new()
			results_table.add_child(label)
	
	print("children: ", results_table.get_child_count())

	mutex = Mutex.new()
	thread = Thread.new()
	err = thread.start(_collect_results)
	if err != OK:
		push_error("Failed to start thread: ", error_string(err))


func _write_result(i: int, average: int) -> void:
	var label: Label = results_table.get_child(i)
	label.text = str(average)


func _collect_results() -> void:
	var i := AI_NAMES.size() + 1
	for white_ai in AI_CLASSES:
		i += 1
		for black_ai in AI_CLASSES:
			var results: Array[int] = []
			for _i in range(RUNS):
				results.append(_run_game(white_ai, black_ai))
			var average: int = results.reduce(func(a: int, b: int) -> int: return a + b)
			call_deferred("_write_result", i, average)
			i += 1


func _run_game(white_ai: AI, black_ai: AI) -> int:
	var game_logic := GameLogic.new()
	game_logic.start()

	while not game_logic.is_game_over:
		var player: AI
		match game_logic.current_player.color:
			GameLogic.PlayerColor.white:
				player = white_ai
			GameLogic.PlayerColor.black:
				player = black_ai
			_:
				push_error("Unknown player color: ", game_logic.current_player.color)
				player = null
		var die := _roll_die()
		game_logic.roll_die(die)
		var move := player.pick_move(game_logic)
		game_logic.apply_move(move)
	
	return (game_logic.pieces - game_logic._white_player.pieces_safe) - (game_logic.pieces - game_logic._black_player.pieces_safe)


func _roll_die() -> int:
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
	return die
