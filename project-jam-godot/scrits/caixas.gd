
extends Node3D

@export var pontoCaixa: Marker3D
@export var rayJogador: RayCast3D
@export var barraCarregamento: ProgressBar

@export var escalaNaMao: float = 0.5
@export var escalaNoChao: Vector3 = Vector3(0.15, 0.15, 0.15)

@export var tempoParaArremessar: float = 1.0
@export var forcaArremesso: float = 12.0

@export var label: Label
@export var fundoDo: ColorRect

@export var rotacaoCaixa: Vector3 = Vector3(-90, -90, 90)

@export var distanciaPegarCaixaSemColisao: float = 3.0
@export var toleranciaPegarCaixa: float = 0.8
@export var input_label2: Label3D 


@export var enderecosCaixas: Array[String] = [
	"A12", "A17", "B15", "C03", "C02",
	"C04", "A13", "B14", "A18", "C01", "B11",
	"F12", "F17", "F15", "F03", "C00",
	"C12", "A15", "B08", "A20", "C06", "B67",
	"V12", "V17", "V15", "V03"

]

var entregasCorretas: int = 0
var enderecosEntregues: Array[String] = []

var estaNaArea := false
var caixaNaMao := false
var segurandoE := false
var tempoSegurando := 0.0

var caixasDisponiveis: Array[MeshInstance3D] = []
var caixaAtual: MeshInstance3D = null

# Libera o monte organizado somente depois das 11 entregas.
var monteLiberado := false


func _ready() -> void:
	add_to_group("sistema_caixas")

	var no_caixas = get_node_or_null("caixas")

	if no_caixas == null:
		push_error("ERRO: nó 'caixas' não encontrado!")
		return

	Gobla.atividadeDahora = "NAOPODEPEGARCAIXA"
	caixasDisponiveis.clear()

	var indice_caixa := 0

	for filho in no_caixas.get_children():
		if filho is MeshInstance3D:
			var caixa := filho as MeshInstance3D

			caixasDisponiveis.append(caixa)
			caixa.set_meta("transform_monte", caixa.transform)

			caixa.set_meta(
				"numero_caixa",
				"%02d" % (indice_caixa + 1)
			)

			var endereco := "SEM DESTINO"

			if indice_caixa < enderecosCaixas.size():
				endereco = enderecosCaixas[indice_caixa]

			caixa.set_meta("endereco_casa", endereco)

			indice_caixa += 1

	print("Caixas encontradas: ", caixasDisponiveis.size())

	if barraCarregamento:
		barraCarregamento.hide()

	if fundoDo:
		fundoDo.hide()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pegar"):
		if caixaNaMao:
			segurandoE = true
			tempoSegurando = 0.0
		else:
			# 1. Tenta pegar uma caixa física solta.
			var caixaSolta := detectar_caixa_solta()

			if caixaSolta != null:
				pegar_caixa_solta(caixaSolta)
			else:
				# 2. Tenta pegar uma caixa entregue SEM colisão.
				var caixaOrganizada := detectar_caixa_entregue()

				if caixaOrganizada != null:
					pegar_caixa_entregue(caixaOrganizada)
				elif estaNaArea:
					# 3. Mantém a coleta do monte inicial.
					pegar_caixa_monte()

	if segurandoE and Input.is_action_pressed("pegar"):
		tempoSegurando += delta

		if barraCarregamento:
			barraCarregamento.show()
			barraCarregamento.value = clampf(
				tempoSegurando / tempoParaArremessar * 100.0,
				0.0,
				100.0
			)

	if segurandoE and Input.is_action_just_released("pegar"):
		segurandoE = false

		if barraCarregamento:
			barraCarregamento.hide()
			barraCarregamento.value = 0.0

		if tempoSegurando >= tempoParaArremessar:
			soltar_caixa(true)
		else:
			soltar_caixa(false)


# Chamado pela área quando as 11 caixas forem entregues.
func liberar_caixas_entregues() -> void:
	monteLiberado = true

	set_meta("todas_caixas_entregues", true)
	set_meta("liberar_entregas", true)

	print("Coleta das caixas organizadas liberada!")


func detectar_caixa_entregue() -> MeshInstance3D:
	var camera := get_viewport().get_camera_3d()

	if camera == null:
		print("ERRO: nenhuma Camera3D ativa!")
		return null

	var origem: Vector3 = camera.global_position
	var direcao: Vector3 = -camera.global_transform.basis.z.normalized()

	var melhorCaixa: MeshInstance3D = null
	var menorDistancia: float = distanciaPegarCaixaSemColisao

	var caixasDoMonte := get_tree().get_nodes_in_group("caixas_entregues")

	for no in caixasDoMonte:
		if not is_instance_valid(no):
			continue

		if not (no is MeshInstance3D):
			continue

		var caixa := no as MeshInstance3D

		# Só permite pegar as caixas depois de serem liberadas.
		if not caixa.get_meta("pode_ser_recolhida", false):
			continue

		var deslocamento: Vector3 = caixa.global_position - origem
		var distanciaFrente: float = deslocamento.dot(direcao)

		if distanciaFrente <= 0.0:
			continue

		if distanciaFrente > distanciaPegarCaixaSemColisao:
			continue

		# Distância entre o centro da caixa e a direção da câmera.
		var pontoMira: Vector3 = origem + direcao * distanciaFrente
		var distanciaLateral: float = caixa.global_position.distance_to(pontoMira)

		if distanciaLateral > toleranciaPegarCaixa:
			continue

		if distanciaFrente < menorDistancia:
			menorDistancia = distanciaFrente
			melhorCaixa = caixa

	return melhorCaixa
# Pega uma caixa organizada sem criar colisão.
func pegar_caixa_entregue(caixa: MeshInstance3D) -> void:
	if not is_instance_valid(caixa):
		return

	if pontoCaixa == null:
		push_error("Atribua o pontoCaixa no Inspector!")
		return

	caixaAtual = caixa

	caixa.remove_from_group("caixas_entregues")
	caixa.set_meta("pode_ser_recolhida", false)

	caixa.reparent(pontoCaixa, false)
	caixa.transform = Transform3D.IDENTITY
	caixa.rotation_degrees = rotacaoCaixa

	definir_escala_global(
		caixa,
		Vector3.ONE * escalaNaMao
	)

	caixaNaMao = true

	atualizar_label_caixa(caixa)

	print(
		"Caixa recolhida do monte: ",
		caixa.get_meta("numero_caixa", "??"),
		" | Destino: ",
		caixa.get_meta("endereco_casa", "SEM DESTINO")
	)


func pegar_caixa_monte() -> void:
	if caixasDisponiveis.is_empty():
		print("Não tem mais caixas no monte inicial!")
		return

	if pontoCaixa == null:
		push_error("Atribua o pontoCaixa no Inspector!")
		return

	var indice := randi_range(0, caixasDisponiveis.size() - 1)
	var caixa := caixasDisponiveis[indice]

	caixasDisponiveis.remove_at(indice)

	caixaAtual = caixa

	caixa.reparent(pontoCaixa, false)
	caixa.transform = Transform3D.IDENTITY
	caixa.rotation_degrees = rotacaoCaixa

	definir_escala_global(
		caixa,
		Vector3.ONE * escalaNaMao
	)

	caixaNaMao = true

	atualizar_label_caixa(caixa)


# Continua usando a colisão para encontrar caixas físicas soltas.
func detectar_caixa_solta() -> RigidBody3D:
	if rayJogador == null:
		return null

	rayJogador.force_raycast_update()

	if not rayJogador.is_colliding():
		return null

	var objeto = rayJogador.get_collider()

	if objeto is RigidBody3D and objeto.is_in_group("caixas_soltas"):
		if objeto.get_meta("entregue_na_area", false):
			return null

		return objeto

	return null


func pegar_caixa_solta(corpo: RigidBody3D) -> void:
	if pontoCaixa == null or not is_instance_valid(corpo):
		return

	var mesh: MeshInstance3D = null

	for filho in corpo.get_children():
		if filho is MeshInstance3D:
			mesh = filho
			break

	if mesh == null:
		print("Não encontrei a mesh dentro da caixa!")
		return

	caixaAtual = mesh

	mesh.reparent(pontoCaixa, false)
	mesh.transform = Transform3D.IDENTITY
	mesh.rotation_degrees = rotacaoCaixa

	definir_escala_global(
		mesh,
		Vector3.ONE * escalaNaMao
	)

	corpo.queue_free()

	caixaNaMao = true

	atualizar_label_caixa(mesh)


func atualizar_label_caixa(caixa: MeshInstance3D) -> void:
	if fundoDo == null or label == null:
		return

	if caixa == null or not is_instance_valid(caixa):
		fundoDo.hide()
		return

	var numero := str(caixa.get_meta("numero_caixa", "??"))
	var endereco := str(caixa.get_meta("endereco_casa", "SEM DESTINO"))

	label.text = "CAIXA: " + numero + "\nPARA A CASA: " + endereco
	fundoDo.show()


func soltar_caixa(arremessar: bool) -> void:
	if caixaAtual == null or not is_instance_valid(caixaAtual):
		caixaNaMao = false

		if fundoDo:
			fundoDo.hide()

		return

	var caixa := caixaAtual
	var cena := get_tree().current_scene

	var corpo := RigidBody3D.new()
	corpo.name = "CaixaSolta"
	corpo.add_to_group("caixas_soltas")

	cena.add_child(corpo)
	corpo.global_transform = caixa.global_transform

	caixa.reparent(corpo, false)
	caixa.transform = Transform3D.IDENTITY
	caixa.rotation_degrees = rotacaoCaixa

	definir_escala_global(caixa, escalaNoChao)

	# A colisão existe somente na caixa solta.
	var colisao := CollisionShape3D.new()
	var forma := BoxShape3D.new()

	forma.size = Vector3.ONE
	colisao.shape = forma

	corpo.add_child(colisao)

	caixaAtual = null
	caixaNaMao = false

	if fundoDo:
		fundoDo.hide()

	if arremessar and rayJogador != null:
		var camera = rayJogador.get_parent()

		if camera is Camera3D:
			var direcao: Vector3 = -camera.global_transform.basis.z
			corpo.apply_central_impulse(direcao * forcaArremesso)


func registrar_caixa_devolvida(caixa: MeshInstance3D) -> void:
	if not is_instance_valid(caixa):
		return

	if not caixasDisponiveis.has(caixa):
		caixasDisponiveis.append(caixa)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaArea = true
		if input_label2 and Gobla.atividadeDahora == "NAOPODEPEGARCAIXA":
			input_label2.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaArea = false
		if input_label2:
			input_label2.hide()


func definir_escala_global(
	no: Node3D,
	escala_desejada: Vector3
) -> void:
	if no == null or not is_instance_valid(no):
		return

	var escala_pai := Vector3.ONE

	if no.get_parent() is Node3D:
		var pai := no.get_parent() as Node3D
		escala_pai = pai.global_transform.basis.get_scale()

	no.scale = Vector3(
		escala_desejada.x / maxf(absf(escala_pai.x), 0.0001),
		escala_desejada.y / maxf(absf(escala_pai.y), 0.0001),
		escala_desejada.z / maxf(absf(escala_pai.z), 0.0001)
	)



func registrar_entrega_correta(endereco: String) -> void:
	entregasCorretas += 1
	enderecosEntregues.append(endereco)

	print(
		"ENTREGAS CORRETAS: ",
		entregasCorretas,
		"/11"
	)

	if entregasCorretas >= 11:
		Gobla.atividadeDahora = "CAIXASENTREGES"
		print("PARABÉNS! TODAS AS 11 CAIXAS FORAM ENTREGUES!")
		print("Objetivo atualizado: voltar para a agência!")
