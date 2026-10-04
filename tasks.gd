# ui/task_label.gd
extends Label

@export var appear_delay: float = 5.0
@export var fade_duration: float = 0.5
@export_enum("en", "es", "fr", "de", "it") var language_code: String = "en"

func _ready() -> void:
	TaskManager.set_task("TASK_003")
	modulate.a = 0.0
	text = ""

	# Connecta el senyal global del TaskManager
	TaskManager.task_changed.connect(_on_task_changed)

	var timer := get_tree().create_timer(appear_delay)
	timer.timeout.connect(_on_show_task)

func _on_show_task() -> void:
	_update_text()
	_fade_in()

func _on_task_changed(_new_id: String) -> void:
	_update_text()

func _update_text() -> void:
	text = TaskManager.get_task_text(language_code.strip_edges())

func _fade_in() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
