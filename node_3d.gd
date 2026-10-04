extends Node3D # o el tipo que sea tu raíz

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	TaskManager.set_task("TASK_001")
	# Al entrar a la escena, desvanecemos de negro a transparente
	var tween := create_tween()
	fade_rect.modulate.a = 2.5
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)
