extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TaskManager.set_task("TASK_002")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
