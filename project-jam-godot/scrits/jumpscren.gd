extends Node3D

@export var imagem_lobo: Sprite3D
@export var camera_susto: Camera3D
@export var animation_player: AnimationPlayer
@export var som_susto: AudioStreamPlayer
@export var flash: ColorRect
@export var hud: Control
@export_group("Animação")
@export var nome_animacao: StringName = &"susto"
@export var tempo_flash: float = 0.45

var cameras_desativadas: Array[Camera3D] = []
var terminou: bool = false


func _ready() -> void:
	hide()

	if is_instance_valid(imagem_lobo):
		imagem_lobo.visible = false
		imagem_lobo.transparency = 0.0

	if is_instance_valid(camera_susto):
		camera_susto.current = false

	if is_instance_valid(flash):
		flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		flash.color = Color(1, 1, 1, 0)
		flash.mouse_filter = Control.MOUSE_FILTER_IGNORE


func iniciar_susto() -> void:
	if terminou:
		return

	terminou = true
	show()

	if not is_instance_valid(camera_susto):
		push_warning("Jumpscare: configure a CameraSusto.")
		finalizar_susto()
		return

	if not is_instance_valid(animation_player):
		push_warning("Jumpscare: configure o AnimationPlayer.")
		finalizar_susto()
		return

	if not animation_player.has_animation(nome_animacao):
		push_warning("Jumpscare: a animação '" + str(nome_animacao) + "' não existe.")
		finalizar_susto()
		return

	# Desativa as câmeras do jogo para a câmera do jumpscare assumir.
	cameras_desativadas.clear()

	for no in get_tree().get_nodes_in_group("cameras_jogo"):
		if no is Camera3D and no != camera_susto:
			var camera: Camera3D = no

			if camera.current:
				cameras_desativadas.append(camera)

			camera.current = false

	# Usa a câmera posicionada dentro da própria cena do jumpscare.
	camera_susto.current = true

	# Mostra o lobo sem alterar a escala ou a posição dele.
	if is_instance_valid(imagem_lobo):
		imagem_lobo.visible = true
		imagem_lobo.transparency = 0.0

	# Flash branco na tela.
	if is_instance_valid(flash):
		flash.color = Color(1, 1, 1, 0.95)

		var tween_flash := create_tween()
		tween_flash.tween_property(
			flash,
			"color:a",
			0.0,
			tempo_flash
		)

	# Som e animação começam juntos.
	if is_instance_valid(som_susto):
		som_susto.play()

	animation_player.play(nome_animacao)

	print("JUMPSCARE: animação iniciada!")

	# Aguarda a animação terminar.
	await animation_player.animation_finished

	# Confere se a cena ainda existe antes de finalizar.
	if not is_inside_tree():
		return

	print("JUMPSCARE: animação terminou!")

	finalizar_susto()


func finalizar_susto() -> void:
	if is_instance_valid(animation_player):
		animation_player.stop()

	if is_instance_valid(som_susto):
		som_susto.stop()

	if is_instance_valid(imagem_lobo):
		imagem_lobo.visible = false

	if is_instance_valid(flash):
		flash.color = Color(1, 1, 1, 0)

	# Desativa a câmera do jumpscare.
	if is_instance_valid(camera_susto):
		camera_susto.current = false

	# Restaura as câmeras que estavam ativas antes do susto.
	for camera in cameras_desativadas:
		if is_instance_valid(camera):
			camera.current = true

	cameras_desativadas.clear()

	# Remove a cena inteira do jogo.
	hud.menu_morte.show()
	hud.hora.hide()
	hud.imagan.hide()
	hud.atividd.hide()
	hud.contagem_regressiva.hide()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_free()
