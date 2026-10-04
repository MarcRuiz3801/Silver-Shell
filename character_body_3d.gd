extends CharacterBody3D

@export var move_speed: float = 2.5
@export var sprint_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.004
@export var min_pitch: float = -1.0
@export var max_pitch: float = 1.0

var max_stamina: float = 170.0
var stamina: float = 170.0
var stamina_regen_speed: float = 10.0
var stamina_use_speed: float = 20.0
var can_run: bool = true

var dialogue_open: bool = false
var mouse_locked: bool = true

@onready var camera_pivot := $CameraPivot
@onready var camera := $CameraPivot/Camera3D

@export var stamina_bar: ProgressBar
var stamina_tween: Tween

func _ready():
	mouse_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
		stamina_bar.modulate.a = 0.0

# Modifiquem la funció per rebre opcionalment l'objecte a mirar
func enter_dialogue(target: Node3D = null):
	dialogue_open = true
	mouse_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	velocity.x = 0
	velocity.z = 0
	
	# Si ens han passat un objecte, girem la càmera cap a ell
	if target:
		mirar_a_objecte(target)

func exit_dialogue():
	dialogue_open = false
	mouse_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Nova funció per fer la rotació suau en 0.7 segons
func mirar_a_objecte(target: Node3D) -> void:
	# 1. Guardem les rotacions actuals per saber d'on venim
	var start_pivot_y = camera_pivot.rotation.y
	var start_cam_x = camera.rotation.x
	
	# 2. Calculem quina hauria de ser la rotació final de l'eix Y (pivot)
	var target_pos_y = target.global_position
	target_pos_y.y = camera_pivot.global_position.y # Sellar l'alçada per girar només en horitzontal
	camera_pivot.look_at(target_pos_y, Vector3.UP)
	var target_pivot_y = camera_pivot.rotation.y
	
	# 3. Calculem quina hauria de ser la rotació final de l'eix X (càmera)
	camera.look_at(target.global_position, Vector3.UP)
	var target_cam_x = camera.rotation.x
	
	# 4. Tornem a posar la càmera com estava instantàniament per fer el camí suau amb el Tween
	camera_pivot.rotation.y = start_pivot_y
	camera.rotation.x = start_cam_x
	
	# 5. Creem el Tween de 0.7 segons utilitzant 'lerp_angle' per evitar que la càmera es torni boja
	var tween = create_tween()
	tween.tween_method(func(t: float):
		camera_pivot.rotation.y = lerp_angle(start_pivot_y, target_pivot_y, t)
		camera.rotation.x = lerp_angle(start_cam_x, target_cam_x, t)
	, 0.0, 1.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _input(event):
	if dialogue_open:
		return

	if event is InputEventMouseButton and event.pressed:
		if not mouse_locked:
			mouse_locked = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return

	if event.is_action_pressed("ui_cancel"):
		mouse_locked = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if mouse_locked and event is InputEventMouseMotion:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		var pitch = camera.rotation.x - event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)
		camera.rotation = Vector3(pitch, 0, 0)

func _physics_process(delta):
	if dialogue_open:
		if not is_on_floor():
			velocity.y -= 9.8 * delta
		move_and_slide()
		return

	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	var cam_basis = camera.global_transform.basis
	var direction = cam_basis * input_dir
	direction.y = 0
	direction = direction.normalized()

	var is_trying_to_run := Input.is_action_pressed("ui_sprint")
	var is_moving := input_dir.length() > 0.0
	var speed = move_speed

	if is_trying_to_run and is_moving and can_run and stamina > 0.0:
		speed = sprint_speed
		stamina -= stamina_use_speed * delta
	else:
		stamina += stamina_regen_speed * delta

	stamina = clamp(stamina, 0.0, max_stamina)

	if stamina <= 0.0:
		can_run = false
	elif stamina > max_stamina * 0.2:
		can_run = true

	if stamina_bar:
		stamina_bar.value = stamina
		_update_stamina_bar_visibility()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()

func _update_stamina_bar_visibility() -> void:
	if not stamina_bar:
		return

	var target_alpha: float = 0.0
	if stamina < max_stamina:
		target_alpha = 1.0

	if stamina_tween and stamina_tween.is_valid() and stamina_tween.is_running():
		stamina_tween.kill()

	stamina_tween = create_tween()
	stamina_tween.tween_property(stamina_bar, "modulate:a", target_alpha, 0.15)
