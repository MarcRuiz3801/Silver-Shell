extends Area3D

@export var player_name: String = "Player"
@export var first_dialogue_path: String = "res://dialogues/knight.dialogue"
@export var second_dialogue_path: String = "res://dialogues/knight_talkedbefore.dialogue"
@export var dialogue_title: String = "start"
@export var task_first_dialogue: String = "TASK_XXX"
@export var task_second_dialogue: String = "TASK_YYY"
@export var objecte_a_mirar: Node3D

# Animacions
@export var use_different_anim_for_dialogue: bool = false
@export var dialogue_animation: String = "talk"
@export var after_dialogue_animation: String = "idle"
@export var animation_player: AnimationPlayer

var first_dialogue_done: bool = false
var can_trigger_again: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.name != player_name:
		return
	
	if not can_trigger_again:
		return
	
	can_trigger_again = false
	TaskManager.in_dialogue = true  # Activa el diàleg
	
	# Canvia a l'animació de diàleg si està activat
	if use_different_anim_for_dialogue and animation_player:
		animation_player.play(dialogue_animation)
	
	var current_path := second_dialogue_path if first_dialogue_done else first_dialogue_path
	var res = load(current_path)
	if res == null:
		push_error("No s'ha pogut carregar el diàleg: " + current_path)
		TaskManager.in_dialogue = false
		return
	
	if body.has_method("enter_dialogue"):
		body.enter_dialogue(objecte_a_mirar)
	
	DialogueManager.show_dialogue_balloon(res, dialogue_title)
	await DialogueManager.dialogue_ended
	
	TaskManager.in_dialogue = false  # Desactiva el diàleg
	
	# Torna a l'animació de després del diàleg
	if use_different_anim_for_dialogue and animation_player:
		animation_player.play(after_dialogue_animation)
	
	if body.has_method("exit_dialogue"):
		body.exit_dialogue()
	
	# Assignar la tasca just després de cada diàleg
	if not first_dialogue_done:
		TaskManager.set_task(task_first_dialogue)
	else:
		TaskManager.set_task(task_second_dialogue)
	
	first_dialogue_done = true

func _on_body_exited(body: Node3D) -> void:
	if body.name != player_name:
		return
	
	can_trigger_again = true
