extends Label

@export var fade_in_time := 0.5
@export var fade_out_time := 0.5

func _ready():
	modulate.a = 0.0
	await get_tree().create_timer(1.5).timeout
	await _fade(0.0, 1.0, fade_in_time)   # aparecer
	await get_tree().create_timer(3.0).timeout
	await _fade(1.0, 0.0, fade_out_time)  # desaparecer

func _fade(from: float, to: float, duration: float) -> void:
	modulate.a = from
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", to, duration)
	await tw.finished
