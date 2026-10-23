
extends ScrollContainer

@export var area_sprites: Control

var arrastando: bool = false
var mouse_inicial_x: float = 0.0
var scroll_inicial: int = 0

func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mouse_filter = Control.MOUSE_FILTER_STOP

	if area_sprites == null:
		push_error("Arraste o Control dos sprites para Area Sprites no Inspector.")
		return

	# Permite que a área de conteúdo seja maior que a vitrine.
	area_sprites.custom_minimum_size.x = calcular_largura_sprites()

func calcular_largura_sprites() -> float:
	var maior_x: float = 0.0

	for filho in area_sprites.get_children():
		if filho is Sprite2D:
			var sprite: Sprite2D = filho
			var largura: float = sprite.position.x + sprite.get_rect().end.x
			maior_x = maxf(maior_x, largura)

	return maxf(maior_x + 30.0, size.x)

func _input(event: InputEvent) -> void:
	if area_sprites == null:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_rect().has_point(get_global_mouse_position()):
				arrastando = true
				mouse_inicial_x = get_global_mouse_position().x
				scroll_inicial = scroll_horizontal
			elif not event.pressed:
				arrastando = false

	elif event is InputEventMouseMotion and arrastando:
		var mouse_atual_x: float = get_global_mouse_position().x
		var deslocamento: float = mouse_atual_x - mouse_inicial_x

		scroll_horizontal = scroll_inicial - int(deslocamento)
