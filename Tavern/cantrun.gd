extends Label

@export var no_jump_label: Label

var tween_run: Tween
var tween_jump: Tween

var shift_pressed := false
var space_pressed := false


func _ready() -> void:
	# Label "Can run"
	visible = false
	modulate.a = 0.0
	
	# Label "Can jump"
	if no_jump_label:
		no_jump_label.visible = false
		no_jump_label.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	
	if event.echo:
		return
	
	# SHIFT
	if event.keycode == KEY_SHIFT:
		if event.pressed:
			shift_pressed = true
			space_pressed = false
			
			# El missatge de saltar desapareix immediatament
			_hide_jump_immediately()
			
			# Mostra i manté el missatge de córrer
			_show_run()
		else:
			shift_pressed = false
			
			# Només fa fade quan deixes anar SHIFT
			_fade_out_run()
	
	# ESPAI
	elif event.keycode == KEY_SPACE:
		if event.pressed:
			space_pressed = true
			shift_pressed = false
			
			# El missatge de córrer desapareix immediatament
			_hide_run_immediately()
			
			# Mostra i manté el missatge de saltar
			_show_jump()
		else:
			space_pressed = false
			
			# Només fa fade quan deixes anar ESPAI
			_fade_out_jump()


func _show_run() -> void:
	if tween_run:
		tween_run.kill()
	
	visible = true
	modulate.a = 1.0


func _show_jump() -> void:
	if not no_jump_label:
		return
	
	if tween_jump:
		tween_jump.kill()
	
	no_jump_label.visible = true
	no_jump_label.modulate.a = 1.0


func _fade_out_run() -> void:
	if tween_run:
		tween_run.kill()
	
	tween_run = create_tween()
	tween_run.set_trans(Tween.TRANS_SINE)
	tween_run.set_ease(Tween.EASE_OUT)
	tween_run.tween_property(self, "modulate:a", 0.0, 1.2)
	tween_run.tween_callback(func() -> void:
		visible = false
	)


func _fade_out_jump() -> void:
	if not no_jump_label:
		return
	
	if tween_jump:
		tween_jump.kill()
	
	tween_jump = create_tween()
	tween_jump.set_trans(Tween.TRANS_SINE)
	tween_jump.set_ease(Tween.EASE_OUT)
	tween_jump.tween_property(no_jump_label, "modulate:a", 0.0, 1.2)
	tween_jump.tween_callback(func() -> void:
		if no_jump_label:
			no_jump_label.visible = false
	)


func _hide_run_immediately() -> void:
	if tween_run:
		tween_run.kill()
	
	visible = false
	modulate.a = 0.0


func _hide_jump_immediately() -> void:
	if not no_jump_label:
		return
	
	if tween_jump:
		tween_jump.kill()
	
	no_jump_label.visible = false
	no_jump_label.modulate.a = 0.0
