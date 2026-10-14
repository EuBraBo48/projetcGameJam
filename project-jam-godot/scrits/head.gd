extends Node3D

var sencibiy = 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sencibiy))
		rotate_x(deg_to_rad(-event.relative.y * sencibiy))
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
