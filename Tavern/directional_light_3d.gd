extends DirectionalLight3D

@export var base_energy: float = 1.0
@export var variation: float = 0.35
@export var speed: float = 12.0

var target_energy: float

func _ready() -> void:
	target_energy = base_energy

func _process(delta: float) -> void:
	if randf() < delta * speed:
		target_energy = base_energy + randf_range(-variation, variation)

	light_energy = lerp(light_energy, target_energy, 8.0 * delta)
