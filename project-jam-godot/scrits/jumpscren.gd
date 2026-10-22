
extends Node3D

@export var imagem_lobo: Sprite3D
@export var flash: ColorRect
@export var som_susto: AudioStreamPlayer

@export var distancia_lobo: float = 1.5
@export var escala_inicial: Vector3 = Vector3(0.05, 0.05, 0.05)
@export var escala_final: Vector3 = Vector3(2.5, 2.5, 2.5)

var terminou: bool = false


func _ready() -> void:
	hide()

	if is_instance_valid(imagem_lobo):
		imagem_lobo.visible = false
		imagem_lobo.scale = escala_inicial

	if is_instance_valid(flash):
		flash.color = Color(1, 1, 1, 0)
		flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# O flash fica por cima da imagem 3D.
	if is_instance_valid(flash):
		var camada := flash.get_parent()
		if camada is CanvasLayer:
			camada.layer = 100


func iniciar_susto() -> void:
	if terminou:
		return

	terminou = true
	show()

	# Faz o lobo aparecer à frente da câmera atual.
	var camera := get_viewport().get_camera_3d()

	if is_instance_valid(imagem_lobo):
		if is_instance_valid(camera):
			var frente := -camera.global_transform.basis.z
			imagem_lobo.global_position = (
				camera.global_position + frente * distancia_lobo
			)

			# A imagem fica virada para a câmera.
			imagem_lobo.look_at(
				camera.global_position,
				Vector3.UP
			)

		imagem_lobo.scale = escala_inicial
		imagem_lobo.visible = true

	# Toca o som junto com o susto.
	if is_instance_valid(som_susto):
		som_susto.play()

	# Flash branco rápido na tela.
	if is_instance_valid(flash):
		flash.color = Color(1, 1, 1, 0.85)
		var tween_flash := create_tween()
		tween_flash.tween_property(
			flash,
			"color:a",
			0.0,
			0.18
		)

	# O lobo salta para perto da câmera.
	if is_instance_valid(imagem_lobo):
		var tween_lobo := create_tween()
		tween_lobo.set_parallel(true)

		tween_lobo.tween_property(
			imagem_lobo,
			"scale",
			escala_final,
			0.16
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		await tween_lobo.finished

		# Tremida da imagem.
		var tween_tremor := create_tween()
		tween_tremor.tween_property(
			imagem_lobo,
			"rotation_degrees:z",
			-5.0,
			0.05
		)
		tween_tremor.tween_property(
			imagem_lobo,
			"rotation_degrees:z",
			5.0,
			0.05
		)
		tween_tremor.tween_property(
			imagem_lobo,
			"rotation_degrees:z",
			0.0,
			0.05
		)

	# Mantém o susto visível por um instante.
	await get_tree().create_timer(1.0).timeout

	if is_instance_valid(imagem_lobo):
		imagem_lobo.visible = false

	if is_instance_valid(flash):
		flash.color = Color(1, 1, 1, 0)

	hide()
 
