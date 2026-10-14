extends CharacterBody3D

const MAX_SPEED = 13.0
const ACCELERATION = 10.0
const BRAKE_FORCE = 30.0
const REVERSE_SPEED = 8.0
const FRICTION = 8.0
const TURN_SPEED = 2.4
const TURN_SPEED_MIN = 0.7

@export var input_label: Label3D
@export var camera_3d: Camera3D
@export var animation_player: AnimationPlayer
@export var door_point: Marker3D   # ← arraste um Marker3D aqui (posição da porta)

var with_player: bool = false
var player: CharacterBody3D = null
var player_near: bool = false

func _ready() -> void:
	if input_label:
		input_label.hide()
	print("CARRO: Sistema iniciado")

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interagir"):
		return

	if not with_player and player_near:
		_enter_car()
	elif with_player:
		_leave_car()

func _enter_car() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	if player == null:
		print("ERRO: jogador não encontrado")
		return
	animation_player.play("Object_438Action")
	await get_tree().create_timer(1).timeout
	with_player = true
	velocity = Vector3.ZERO
	player.enter_car()

	if camera_3d:
		camera_3d.current = true

	print("CARRO: Jogador entrou")

func _leave_car() -> void:
	with_player = false
	velocity = Vector3.ZERO

	if camera_3d:
		camera_3d.current = false

	if player:
		# Sai exatamente na porta
		if door_point:
			player.global_position = door_point.global_position
		else:
			# fallback caso não tenha colocado o Marker3D
			player.global_position = global_position + global_basis.x * 2.2 + Vector3(0, 1.1, 0)
		
		player.leave_car()

	if input_label:
		input_label.hide()
	player_near = false
	print("CARRO: Jogador saiu")

func _physics_process(delta: float) -> void:
	if not with_player:
		velocity = Vector3.ZERO
		return

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var steer = -input_dir.x

	var speed = Vector2(velocity.x, velocity.z).length()

	# Direção
	var turn_amount = lerp(TURN_SPEED_MIN, TURN_SPEED, clamp(speed / MAX_SPEED, 0.0, 1.0))
	if speed > 0.5:
		rotate_y(steer * turn_amount * delta)

	# Direção para frente
	var forward = -global_transform.basis.x
	forward.y = 0
	forward = forward.normalized()

	# === CONTROLES COM PRIORIDADE ===
	if Input.is_action_pressed("ui_accept"):		# ESPAÇO = freio (prioridade máxima)
		velocity.x = move_toward(velocity.x, 0.0, BRAKE_FORCE * delta)
		velocity.z = move_toward(velocity.z, 0.0, BRAKE_FORCE * delta)
	elif Input.is_action_pressed("ui_up"):			# W = acelera
		velocity += forward * ACCELERATION * delta
	elif Input.is_action_pressed("ui_down"):		# S = ré
		velocity += -forward * REVERSE_SPEED * delta
	else:
		# Freio natural
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

	# Limite de velocidade
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	if horizontal_vel.length() > MAX_SPEED:
		horizontal_vel = horizontal_vel.normalized() * MAX_SPEED
		velocity.x = horizontal_vel.x
		velocity.z = horizontal_vel.z

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not with_player:
		player_near = true
		if input_label:
			input_label.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and not with_player:
		player_near = false
		if input_label:
			input_label.hide()


func _on_p_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		animation_player.play("ABRIPORTA")


func _on_p_1_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		pass
