class_name GameTypes
extends Node

enum {DICE_D4x1, DICE_D3x2, DICE_D2x3, DICE_D2x4}
enum {PATH_BELL, PATH_MASTER, PATH_MURRAY, PATH_SKIRIUK}

var dice = DICE_D2x4
var path = PATH_BELL
var pieces = 5
var rosette_safe = true
var rosette_extra_turn = false
var capture_extra_turn = false
