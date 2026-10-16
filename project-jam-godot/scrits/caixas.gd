extends Node3D

@export var pontoCaixa: Marker3D
@export var rayJogador: RayCast3D
@export var barraCarregamento: ProgressBar

@export var escalaNaMao: float = 0.7
@export var tempoParaArremessar: float = 1.0
@export var forcaArremesso: float = 12.0
@export var label: Label
@export var fundoDo: ColorRect 


# Endereço de cada caixa, na ordem dos filhos
# dentro do nó "caixas".
@export var enderecosCaixas: Array[String] = [
	"A12",
	"A17",
	"B15",
	"C03",
	"C03",
	"C03",
	"A12",
	"B15",
	"A17",
	"C03",
	"B15"
]

var estaNaArea = false
var caixaNaMao = false
var segurandoE = false
var tempoSegurando = 0.0

var caixasDisponiveis: Array[MeshInstance3D] = []
var caixaAtual: MeshInstance3D = null
var escalaOriginal: Vector3 = Vector3.ONE


func _ready() -> void:
	var no_caixas = get_node("caixas")

	Gobla.caixaCOLETADA = true

	var indice_caixa = 0

	for filho in no_caixas.get_children():
		if filho is MeshInstance3D:
			caixasDisponiveis.append(filho)

			# Cada mesh recebe seu número e endereço.
			filho.set_meta(
				"numero_caixa",
				"%02d" % (indice_caixa + 1)
			)

			var endereco = "SEM DESTINO"

			if indice_caixa < enderecosCaixas.size():
				endereco = enderecosCaixas[indice_caixa]

			filho.set_meta("endereco_casa", endereco)

			indice_caixa += 1

	print("Caixas encontradas: ", caixasDisponiveis.size())

	if barraCarregamento:
		barraCarregamento.visible = false

	if fundoDo:
		fundoDo.hide()


func _process(delta: float) -> void:
	# Começou a apertar E.
	if Input.is_action_just_pressed("pegar"):
		if caixaNaMao:
			segurandoE = true
			tempoSegurando = 0.0
		else:
			var caixaSolta = detectar_caixa_solta()

			if caixaSolta != null:
				pegar_caixa_solta(caixaSolta)
			elif estaNaArea:
				pegar_caixa_monte()

	# Atualiza a barra enquanto segura E.
	if segurandoE and Input.is_action_pressed("pegar"):
		tempoSegurando += delta

		if barraCarregamento:
			barraCarregamento.visible = true
			barraCarregamento.value = clampf(
				tempoSegurando / tempoParaArremessar * 100.0,
				0.0,
				100.0
			)

	# Soltou E.
	if segurandoE and Input.is_action_just_released("pegar"):
		segurandoE = false

		if barraCarregamento:
			barraCarregamento.visible = false
			barraCarregamento.value = 0

		if tempoSegurando >= tempoParaArremessar:
			soltar_caixa(true)
		else:
			soltar_caixa(false)


func atualizar_label_caixa(caixa: MeshInstance3D) -> void:
	if fundoDo == null:
		return

	if caixa == null or not is_instance_valid(caixa):
		fundoDo.hide()
		return

	var numero = str(
		caixa.get_meta("numero_caixa", "??")
	)

	var endereco = str(
		caixa.get_meta("endereco_casa", "SEM DESTINO")
	)

	label.text = (
		"CAIXA: " + numero
		+ "\nPARA A CASA: " + endereco
	)

	fundoDo.show()


func pegar_caixa_monte() -> void:
	if caixasDisponiveis.is_empty():
		print("Não tem mais caixas no monte!")
		return

	if pontoCaixa == null:
		print("ERRO: atribua o PontoCaixa no Inspector!")
		return

	var indice = randi_range(
		0,
		caixasDisponiveis.size() - 1
	)

	var caixa = caixasDisponiveis[indice]

	caixasDisponiveis.remove_at(indice)

	escalaOriginal = caixa.scale
	caixaAtual = caixa

	caixa.reparent(pontoCaixa, false)
	caixa.transform = Transform3D.IDENTITY
	caixa.scale = Vector3(0.5, 0.5, 0.5)

	caixaNaMao = true

	atualizar_label_caixa(caixa)


func detectar_caixa_solta() -> RigidBody3D:
	if rayJogador == null:
		return null

	rayJogador.force_raycast_update()

	if not rayJogador.is_colliding():
		return null

	var objeto = rayJogador.get_collider()

	if objeto is RigidBody3D and objeto.is_in_group("caixas_soltas"):
		return objeto

	return null


func pegar_caixa_solta(corpo: RigidBody3D) -> void:
	if pontoCaixa == null:
		print("ERRO: atribua o PontoCaixa no Inspector!")
		return

	if not is_instance_valid(corpo):
		return

	# Procura a mesh dentro do corpo físico.
	var mesh: MeshInstance3D = null

	for filho in corpo.get_children():
		if filho is MeshInstance3D:
			mesh = filho
			break

	if mesh == null:
		print("Não encontrei a mesh dentro da caixa!")
		return

	escalaOriginal = mesh.scale
	caixaAtual = mesh

	# A identificação continua na mesh
	# mesmo depois de soltar e pegar novamente.
	mesh.reparent(pontoCaixa, false)
	mesh.transform = Transform3D.IDENTITY
	mesh.scale = Vector3(0.5, 0.5, 0.5)

	corpo.queue_free()

	caixaNaMao = true

	atualizar_label_caixa(mesh)


func soltar_caixa(arremessar: bool) -> void:
	if caixaAtual == null or not is_instance_valid(caixaAtual):
		caixaNaMao = false

		if fundoDo:
			fundoDo.hide()

		return

	var caixa = caixaAtual
	var cena = get_tree().current_scene

	# Cria o corpo físico no local da caixa.
	var corpo = RigidBody3D.new()
	corpo.name = "CaixaSolta"
	corpo.add_to_group("caixas_soltas")

	cena.add_child(corpo)
	corpo.global_transform = caixa.global_transform

	# Coloca a mesh dentro do corpo.
	# Os metadados de identificação são preservados.
	caixa.reparent(corpo, false)
	caixa.transform = Transform3D.IDENTITY
	caixa.scale = Vector3(0.5, 0.5, 0.5)

	# Cria uma colisão física simples.
	var colisao = CollisionShape3D.new()
	var forma = BoxShape3D.new()

	forma.size = Vector3.ONE
	colisao.shape = forma
	corpo.add_child(colisao)

	caixaAtual = null
	caixaNaMao = false

	# Sem caixa na mão, esconde o texto.
	if fundoDo:
		fundoDo.hide()

	if arremessar:
		var camera = rayJogador.get_parent() if rayJogador else null

		if camera is Camera3D:
			var direcao = -camera.global_transform.basis.z
			corpo.apply_central_impulse(
				direcao * forcaArremesso
			)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaArea = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaArea = false
