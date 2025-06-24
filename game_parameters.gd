class_name GameTypes
extends Node

enum {DICE_D4x1, DICE_D3x2, DICE_D2x3, DICE_D2x4}
enum Path {BELL, MASTER, MURRAY, SKIRIUK}

var dice := DICE_D2x4
var path := Path.BELL
var pieces := 5
var rosette_safe := true
var rosette_extra_turn := false
var capture_extra_turn := false


# 14 15 16 17       18 19
#  6  7  8  9 10 11 12 13
#  0  1  2  3        4  5

var white_path: Array[int]:
	get:
		match path:
			Path.BELL:
				return [3, 2, 1, 0, 6, 7, 8, 9, 10, 11, 12, 13, 5, 4]
			Path.MASTER:
				return [3, 2, 1, 0, 6, 7, 8, 9, 10, 11, 12, 18, 19, 13, 5, 4]
			Path.MURRAY:
				return [3, 2, 1, 0, 6, 7, 8, 9, 10, 11, 12, 18, 19, 13, 5, 4, 12, 11, 10, 9, 8, 7, 6, 14, 15, 16, 17]
			Path.SKIRIUK:
				return [3, 2, 1, 0, 6, 7, 8, 9, 10, 11, 12, 18, 19, 13, 5, 4, 12, 11, 10, 9, 8, 7, 6]
			_:
				push_error("Invalid path: ", path)
				return []
var black_path: Array[int]:
	get:
		match path:
			Path.BELL:
				return [17, 16, 15, 14, 6, 7, 8, 9, 10, 11, 12, 13, 19, 18]
			Path.MASTER:
				return [17, 16, 15, 14, 6, 7, 8, 9, 10, 11, 12, 4, 5, 13, 19, 18]
			Path.MURRAY:
				return [17, 16, 15, 14, 6, 7, 8, 9, 10, 11, 12, 4, 5, 13, 19, 18, 12, 11, 10, 9, 8, 7, 6, 0, 1, 2, 3]
			Path.SKIRIUK:
				return [17, 16, 15, 14, 6, 7, 8, 9, 10, 11, 12, 4, 5, 13, 19, 18, 12, 11, 10, 9, 8, 7, 6]
			_:
				push_error("Invalid path: ", path)
				return []
