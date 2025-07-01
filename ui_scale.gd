extends Node


func _ready() -> void:
	var display_scale := DisplayServer.screen_get_scale()
	var window := get_window()
	window.content_scale_factor = display_scale
