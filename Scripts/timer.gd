extends Node

# Permet modificar els segons d'espera des de l'inspector
@export var temps_espera: float = 3.0

# Permet seleccionar la ruta de la següent escena des de l'inspector
@export_file("*.tscn") var seguent_escena: String

func _ready() -> void:
	# Verifiquem que s'hagi assignat una escena per evitar errors
	if seguent_escena == "":
		push_warning("No s'ha assignat cap escena de destí a l'inspector.")
		return
		
	# Creem un temporitzador d'un sol ús (SceneTreeTimer) i esperem que acabi
	await get_tree().create_timer(temps_espera).timeout
	
	# Cambiem a la següent escena
	get_tree().change_scene_to_file(seguent_escena)
