extends CharacterBody3D

const MAX_SPEED = 13.0
const ACCELERATION = 10.0
const BRAKE_FORCE = 30.0
const REVERSE_SPEED = 40.0
const FRICTION = 8.0
const TURN_SPEED = 2.4
const TURN_SPEED_MIN = 0.7

const MOUSE_SENSITIVITY = 0.002
const CAMERA_MIN_ANGLE = -40.0
const CAMERA_MAX_ANGLE = 25.0
const CAMERA_SMOOTH = 10.0

@export var input_label: Label3D
@export var input_label2: Label3D
@export var camera_3d: Camera3D
@export var animation_player: AnimationPlayer
@export var door_point: Marker3D

var porta_aberta: bool = false
var with_player: bool = false
var player: CharacterBody3D = null
var player_near: bool = false
var estAre := false

var camera_yaw: float = 0.0
var camera_pitch: float = 0.0

var camera_yaw_alvo: float = 0.0
var camera_pitch_alvo: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if camera_3d:
		camera_yaw = camera_3d.rotation.y
		camera_pitch = camera_3d.rotation.x

		camera_yaw_alvo = camera_yaw
		camera_pitch_alvo = camera_pitch

	if input_label:
		input_label.hide()

	if input_label2:
		input_label2.hide()

	print("CARRO: Sistema iniciado")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interagir"):
		if not with_player and player_near:
			_enter_car()
		elif with_player:
			_leave_car()
		return

	if with_player and camera_3d and event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			camera_yaw_alvo -= event.relative.x * MOUSE_SENSITIVITY
			camera_pitch_alvo -= event.relative.y * MOUSE_SENSITIVITY

			camera_pitch_alvo = clamp(
				camera_pitch_alvo,
				deg_to_rad(CAMERA_MIN_ANGLE),
				deg_to_rad(CAMERA_MAX_ANGLE)
			)


func _enter_car() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	if player == null:
		print("ERRO: jogador não encontrado")
		return

	if animation_player:
		animation_player.play("Object_438Action")
		await get_tree().create_timer(1.0).timeout

	if not is_instance_valid(player):
		return

	with_player = true
	velocity = Vector3.ZERO

	player.enter_car()

	if camera_3d:
		camera_3d.current = true

		camera_yaw = camera_3d.rotation.y
		camera_pitch = camera_3d.rotation.x

		camera_yaw_alvo = camera_yaw
		camera_pitch_alvo = camera_pitch

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print("CARRO: Jogador entrou")


func _leave_car() -> void:
	with_player = false
	velocity = Vector3.ZERO

	if camera_3d:
		camera_3d.current = false

	if player and is_instance_valid(player):
		if door_point:
			player.global_position = door_point.global_position
		else:
			player.global_position = (
				global_position
				+ global_basis.x * 2.2
				+ Vector3(0, 1.1, 0)
			)

		player.leave_car()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if input_label:
		input_label.hide()

	if input_label2:
		input_label2.hide()

	player_near = false

	print("CARRO: Jogador saiu")


func _process(delta: float) -> void:
	if with_player and camera_3d:
		camera_yaw = lerp_angle(
			camera_yaw,
			camera_yaw_alvo,
			1.0 - exp(-CAMERA_SMOOTH * delta)
		)

		camera_pitch = lerp_angle(
			camera_pitch,
			camera_pitch_alvo,
			1.0 - exp(-CAMERA_SMOOTH * delta)
		)

		camera_3d.rotation.y = camera_yaw
		camera_3d.rotation.x = camera_pitch

	if estAre and Input.is_action_just_pressed("interagir"):
		if animation_player:
			if porta_aberta:
				animation_player.play("fechaPORTA")
				porta_aberta = false
			else:
				animation_player.play("ABRIPORTA")
				porta_aberta = true


func _physics_process(delta: float) -> void:
	if not with_player:
		velocity = Vector3.ZERO
		return

	var forward = -global_transform.basis.x
	forward.y = 0.0
	forward = forward.normalized()

	var horizontal_vel = Vector3(velocity.x, 0.0, velocity.z)
	var speed = horizontal_vel.dot(forward)

	var acelerando = Input.is_action_pressed("ui_up")
	var dando_re = Input.is_action_pressed("ui_down")
	var freando = Input.is_action_pressed("ui_accept")

	# Aceleração para frente, ré e freio
	if freando:
		speed = move_toward(speed, 0.0, BRAKE_FORCE * delta)

	elif acelerando and not dando_re:
		if speed < 0.0:
			speed = move_toward(speed, 0.0, 80.0 * delta)
		else:
			speed = move_toward(speed, MAX_SPEED, ACCELERATION * delta)

	elif dando_re and not acelerando:
		# Ré mais rápida
		speed = -move_toward(
			abs(speed),
			REVERSE_SPEED,
			150.0 * delta
		)

	else:
		speed = move_toward(speed, 0.0, FRICTION * delta)

	# Direção sem perda artificial de velocidade
	var steer = Input.get_axis("ui_left", "ui_right")

	if abs(steer) > 0.01 and abs(speed) > 0.1:
		var fator_velocidade = clamp(
			abs(speed) / MAX_SPEED,
			0.0,
			1.0
		)

		var turn_amount = lerp(
			TURN_SPEED_MIN,
			TURN_SPEED,
			fator_velocidade
		)

		var sentido = 1.0 if speed > 0.0 else -1.0
		rotate_y(-steer * turn_amount * sentido * delta)

	# Recalcula a direção após virar
	forward = -global_transform.basis.x
	forward.y = 0.0
	forward = forward.normalized()

	velocity.x = forward.x * speed
	velocity.z = forward.z * speed

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


func _on_port_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estAre = true
		if input_label2:
			input_label2.show()


func _on_port_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estAre = false
		if input_label2:
			input_label2.hide()
