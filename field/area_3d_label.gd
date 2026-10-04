extends Area3D

@export var missatge: String = "Has entrat a l'àrea"
@export var label_node: Label  # Assigna la Label des de l'inspector

func _ready() -> void:
	# Inicialment amaguem la label
	if label_node:
		label_node.visible = false
	else:
		push_warning("No s'ha assignat cap Label a label_node")
	
	# Connectem els senyals d'entrada i sortida de cossos
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and label_node:
		label_node.text = missatge
		label_node.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player" and label_node:
		label_node.visible = false
