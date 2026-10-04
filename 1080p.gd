# set_resolution_1080p.gd
extends Node

func _ready() -> void:
	get_tree().root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	
	var screen_size := DisplayServer.screen_get_size()
	DisplayServer.window_set_position(
		Vector2i((screen_size.x - 1920) / 2, (screen_size.y - 1080) / 2)
	)
