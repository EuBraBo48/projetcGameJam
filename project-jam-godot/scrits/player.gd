extends CharacterBody3D

const SPEED = 5.0
const DASH_SPEED = 10.0
const JUMP_VELOCITY = 3.5

const DASH_TEMPO_MAX: float = 3.0
const DASH_RECARGA_TEMPO: float = 5.0

@export var ray_cast_3d: RayCast3D
@export var barra_dash: ProgressBar

var dirigindo: bool = false

@export var m_1: Node3D
@export var m_2: Node3D
@export var m_3: Node3D
@export var m_4: Node3D
@export var m_5: Node3D

var dash_tempo: float = DASH_TEMPO_MAX
var dash_recarregando: bool = false
var dash_ativo: bool = false


func _ready() -> void:
	if barra_dash != null:
		barra_dash.max_value = DASH_TEMPO_MAX
		barra_dash.value = DASH_TEMPO_MAX
		barra_dash.hide()


func _physics_process(delta: float) -> void:
	if dirigindo:
		return

	var shift_pressionado := Input.is_key_pressed(KEY_SHIFT)

	# A barra só recarrega depois que soltar o Shift.
	if dash_recarregando:
		if not shift_pressionado:
			dash_tempo = move_toward(
				dash_tempo,
				DASH_TEMPO_MAX,
				(DASH_TEMPO_MAX / DASH_RECARGA_TEMPO) * delta
			)

			if dash_tempo >= DASH_TEMPO_MAX:
				dash_recarregando = false

	# Ativa o dash somente se houver energia e não estiver recarregando.
	dash_ativo = (
		shift_pressionado
		and dash_tempo > 0.0
		and not dash_recarregando
	)

	# Consome a energia durante o dash.
	if dash_ativo:
		dash_tempo = maxf(dash_tempo - delta, 0.0)

		if dash_tempo <= 0.0:
			dash_ativo = false
			dash_recarregando = true

	# Atualiza a barra de energia.
	if barra_dash != null:
		barra_dash.value = dash_tempo

		if dash_ativo or dash_recarregando:
			barra_dash.show()
		else:
			barra_dash.hide()

	# Gravidade original.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo original.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento original.
	var input_dir := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var direction := (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	var velocidade_atual: float = DASH_SPEED if dash_ativo else SPEED

	if direction:
		velocity.x = direction.x * velocidade_atual
		velocity.z = direction.z * velocidade_atual
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func enter_car() -> void:
	dirigindo = true
	dash_ativo = false
	velocity = Vector3.ZERO
	set_physics_process(false)
	hide()
	$CollisionShape3D.set_deferred("disabled", true)
	$Camera3D.current = false
	print("PLAYER: entrou no carro")


func leave_car() -> void:
	dirigindo = false
	velocity = Vector3.ZERO
	$CollisionShape3D.set_deferred("disabled", false)
	show()
	set_physics_process(true)
	$Camera3D.current = true
	print("PLAYER: saiu do carro")
