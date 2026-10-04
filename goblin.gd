extends CharacterBody3D

# ─── PARÀMETRES ────────────────────────────────────────────────
@export var walk_speed      : float = 2.5
@export var run_speed       : float = 5.5
@export var attack_range    : float = 1.4   # distància per atacar
@export var retreat_dist    : float = 3.5   # distància del 10% de "apartat"
@export var attack_cooldown : float = 0.9   # temps entre atacs
@export var damage          : int   = 10
@export var hp              : int   = 30

# ─── REFERÈNCIES ────────────────────────────────────────────────
@onready var anim : AnimationPlayer  = $AnimationPlayer
@onready var nav  : NavigationAgent3D = $NavigationAgent3D
@onready var area : Area3D            = $Area3D   # <-- canvia pel nom exacte del teu node

# ─── ANIMACIONS (noms exactes del teu AnimationPlayer) ──────────
const ANIM_IDLE         = "standing idle 01/mixamo_com"
const ANIM_WALK_FORWARD = "standing walk forward/mixamo_com"
const ANIM_WALK_BACK    = "standing walk back/mixamo_com"
const ANIM_WALK_LEFT    = "standing walk left/mixamo_com"
const ANIM_WALK_RIGHT   = "standing walk right/mixamo_com"
const ANIM_TURN_LEFT    = "standing turn 90 left/mixamo_com"
const ANIM_TURN_RIGHT   = "standing turn 90 right/mixamo_com"

# ─── ESTAT ──────────────────────────────────────────────────────
enum State { CHASE, ATTACK, RETREAT, DEAD }
var state         : State = State.CHASE
var player        : Node3D = null
var attack_timer  : float = 0.0
var retreat_timer : float = 0.0   # quant temps estar apartat

const GRAVITY = -9.8

# ─── INICIALITZACIÓ ─────────────────────────────────────────────
func _ready() -> void:
	# Busca el jugador directament al grup, no depèn de l'Area3D per trobar-lo
	for a in $AnimationPlayer.get_animation_list():
		push_error(a)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	area.body_entered.connect(_on_body_entered)

	# 90% del temps comença en CHASE, 10% en RETREAT
	if randf() < 0.9:
		_enter_chase()
	else:
		_enter_retreat()

# ─── BUCLE PRINCIPAL ────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	match state:
		State.CHASE:   _tick_chase(delta)
		State.ATTACK:  _tick_attack(delta)
		State.RETREAT: _tick_retreat(delta)

	move_and_slide()

# ─── CHASE (perseguir jugador) ───────────────────────────────────
func _enter_chase() -> void:
	state = State.CHASE
	_play(ANIM_WALK_FORWARD)

func _tick_chase(delta: float) -> void:
	if not _player_valid():
		return

	var dist = _dist_to_player()

	if dist <= attack_range:
		_enter_attack()
		return

	# Mou cap al jugador
	nav.target_position = player.global_position
	_move_toward_nav(run_speed)
	_face_player()

# ─── ATTACK ──────────────────────────────────────────────────────
func _enter_attack() -> void:
	state = State.ATTACK
	attack_timer = 0.0
	velocity.x = 0
	velocity.z = 0
	_do_attack()

func _tick_attack(delta: float) -> void:
	if not _player_valid():
		_enter_chase()
		return

	attack_timer -= delta

	# Si el jugador s'ha allunyat, torna a perseguir
	if _dist_to_player() > attack_range * 1.4:
		_enter_chase()
		return

	# Cada cert temps, 10% de probabilitat de fer retreat
	if attack_timer <= 0.0:
		if randf() < 0.1:
			_enter_retreat()
		else:
			_do_attack()

func _do_attack() -> void:
	attack_timer = attack_cooldown
	_face_player()

	# Alterna entre turn left i right per fer-ho més viu
	if randf() < 0.5:
		_play(ANIM_TURN_LEFT)
	else:
		_play(ANIM_TURN_RIGHT)

	# Aplica dany al mig de l'animació
	await get_tree().create_timer(0.45).timeout
	if state != State.ATTACK or not _player_valid():
		return
	if _dist_to_player() <= attack_range * 1.2:
		if player.has_method("take_damage"):
			player.take_damage(damage)

# ─── RETREAT (apartat, 10% del temps) ───────────────────────────
func _enter_retreat() -> void:
	state = State.RETREAT
	retreat_timer = randf_range(1.5, 3.5)   # entre 1.5 i 3.5 seg apartat
	_play(ANIM_WALK_BACK)

func _tick_retreat(delta: float) -> void:
	if not _player_valid():
		_enter_chase()
		return

	retreat_timer -= delta

	# Camina en direcció contrària al jugador
	var dir_away = (global_position - player.global_position).normalized()
	dir_away.y = 0.0
	velocity.x = dir_away.x * walk_speed
	velocity.z = dir_away.z * walk_speed
	_face_player()   # mira al jugador mentre recua (sembla més natural)

	# Si ja está prou lluny o s'ha acabat el temps, torna a atacar
	if retreat_timer <= 0.0 or _dist_to_player() >= retreat_dist:
		_enter_chase()

# ─── REBRE DANY ──────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	hp -= amount
	if hp <= 0:
		_die()

func _die() -> void:
	state = State.DEAD
	velocity = Vector3.ZERO
	queue_free()

# ─── DETECCIÓ (per si el jugador entra tard a l'escena) ─────────
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and player == null:
		player = body

# ─── HELPERS ─────────────────────────────────────────────────────
func _player_valid() -> bool:
	return player != null and is_instance_valid(player)

func _dist_to_player() -> float:
	return global_position.distance_to(player.global_position)

func _face_player() -> void:
	if not _player_valid():
		return
	var look_pos = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	if look_pos != global_position:
		look_at(look_pos, Vector3.UP)
		rotate_y(PI)

func _move_toward_nav(speed: float) -> void:
	if nav.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return
	var next = nav.get_next_path_position()
	var dir = (next - global_position).normalized()
	dir.y = 0.0
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func _play(anim_name: String) -> void:
	if anim.current_animation == anim_name:
		return
	if anim.has_animation(anim_name):
		anim.play(anim_name)
	else:
		push_warning("Goblin: animació no trobada -> " + anim_name)
