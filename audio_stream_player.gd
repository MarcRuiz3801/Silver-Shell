extends AudioStreamPlayer

@export var music: AudioStreamPlayer

func _ready():
	# Espera 1.5 segundos antes de empezar la música
	await get_tree().create_timer(1.5).timeout
	if music:
		music.play()
