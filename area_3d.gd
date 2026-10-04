extends Area3D

@export var fade_rect: ColorRect
@export var fade_duration: float = 1.0
@export var next_scene_path: String = "res://escenes/la_teva_escena.tscn"

func _on_body_entered(body: Node3D) -> void:
	# Només activar si el cos es diu "Player"
	if body.name != "Player":
		return

	push_error("TRIGGER ACTIVADO POR: %s" % body.name)

	if fade_rect == null:
		push_error("fade_rect es null, arrastra el FadeRect en el inspector")
		return

	# Assegurem que està visible i amb alpha 0
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0

	var tween := get_tree().create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)

	# Quan acabi el tween (fade complet), canviem d'escena
	tween.tween_callback(_change_scene)


func _change_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
