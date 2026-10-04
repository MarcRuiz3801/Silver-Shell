# set_resolution_720p.gd
extends Node

func _ready() -> void:
	get_tree().root.content_scale_size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	
	var screen_size := DisplayServer.screen_get_size()
	DisplayServer.window_set_position(
		Vector2i((screen_size.x - 1280) / 2, (screen_size.y - 720) / 2)
	)
