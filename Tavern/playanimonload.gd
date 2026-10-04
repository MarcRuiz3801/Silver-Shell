extends AnimationPlayer

## Nom de l'animació que es reproduirà en bucle infinit des de l'inici.
## Escriu exactament el nom que apareix a la llista d'animacions.
@export var animacio_inicial: String = ""

## Activa/desactiva el bucle infinit.
@export var bucle_infinit: bool = true

func _ready() -> void:
	if animacio_inicial.is_empty():
		return  # No fem res si no s'ha triat animació

	# Assegurem que l'animació existeix
	if not has_animation(animacio_inicial):
		push_warning("L'animació '%s' no existeix a aquest AnimationPlayer." % animacio_inicial)
		return

	# Si volem bucle infinit, activem el loop mode de l'animació
	if bucle_infinit:
		var anim: Animation = get_animation(animacio_inicial)
		# Godot 4: loop_mode és un enum (Animation.LOOP_NONE, LOOP_LINEAR, etc.)
		anim.loop_mode = Animation.LOOP_LINEAR

	# Reproduïm l'animació des de l'inici
	play(animacio_inicial)
