extends Camera3D

@export_group("Head Bob")

@export var bob_frequency: float = 9.0
@export var bob_amplitude: float = 0.035
@export var bob_side_amplitude: float = 0.02
@export var smooth_speed: float = 12.0

var bob_time: float = 0.0
var original_position: Vector3


func _ready() -> void:
	original_position = position


func _process(delta: float) -> void:
	var input_vector := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var is_moving := input_vector.length() > 0.0

	var target_position := original_position

	if is_moving:
		bob_time += delta * bob_frequency

		target_position.y += sin(bob_time) * bob_amplitude
		target_position.x += cos(bob_time * 0.5) * bob_side_amplitude
	else:
		bob_time = 0.0

	position = position.lerp(
		target_position,
		smooth_speed * delta
	)
