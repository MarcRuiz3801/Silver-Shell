extends Sprite2D

# Configura les unitats que avançarà el ganivet
@export var distancia: float = 50.0
# Configura la velocitat del moviment (opcional, per ajustar el temps)
@export var velocitat: float = 300.0

# Assigna el fitxer de so MP3 aquí
@export var so_mp3: AudioStreamMP3

# Vector de direcció (diagonal cap a dalt-esquerra)
@export var direccio_moviment: Vector2 = Vector2(-1, -1).normalized()

var posicio_inicial: Vector2
var movent_se: bool = false
var sentit: int = 1  # 1 = endavant, -1 = endarrere

func _ready():
	posicio_inicial = position

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Només permet moure si NO estàs en diàleg
		if not movent_se and not TaskManager.in_dialogue:
			movent_se = true
			sentit = 1
			# Reprodueix el so
			if so_mp3:
				var player = AudioStreamPlayer.new()
				player.stream = so_mp3
				add_child(player)
				player.play()
				player.finished.connect(func(): player.queue_free())

func _process(delta):
	# Atura el moviment si estàs en diàleg
	if TaskManager.in_dialogue:
		return
	
	if movent_se:
		var moviment = sentit * direccio_moviment * velocitat * delta
		position += moviment

		var distancia_recorreguda = position.distance_to(posicio_inicial)
		if distancia_recorreguda >= distancia:
			if sentit == 1:
				sentit = -1
			else:
				movent_se = false
				position = posicio_inicial
