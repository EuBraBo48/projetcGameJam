extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 3.5

var dirigindo: bool = false

func _physics_process(delta: float) -> void:
	if dirigindo:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func enter_car() -> void:
	dirigindo = true
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
