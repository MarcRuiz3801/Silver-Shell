extends Control

@export_file("*.tscn") var game_scene_path: String = "res://node_3d.tscn"

@onready var play_button: Button = $PlayButton
@onready var exit_button: Button = $ExitButton
@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	# Fem un fundido a negre abans de canviar d'escena
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	tween.finished.connect(_on_fade_done)

func _on_fade_done() -> void:
	get_tree().change_scene_to_file(game_scene_path)

func _on_exit_pressed() -> void:
	get_tree().quit()
