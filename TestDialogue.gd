extends Node

func _ready() -> void:
	var res = load("res://dialogues/knight.dialogue")
	print("RES:", res)
	await DialogueManager.show_dialogue_balloon(res, "start")
