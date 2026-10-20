
extends Area3D

@export var marcadorMonte: Marker3D
@export var escalaCaixa: Vector3 = Vector3(0.15, 0.15, 0.15)

@export var caixasPorColuna: int = 3
@export var caixasDeAltura: int = 2
@export var espacamentoX: float = 0.35
@export var espacamentoY: float = 0.30
@export var espacamentoZ: float = 0.35

@export var totalCaixasNecessarias: int = 11

# Arraste aqui o Node3D que possui o segundo script.
@export var sistemaCaixas: Node3D

@export var rotacaoCaixa: Vector3 = Vector3(-90, -90, 90)

var caixasEntregues: Array[MeshInstance3D] = []
var recipienteCaixas: Node3D = null
var entregaCompleta: bool = false


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func criar_recipiente() -> void:
	if is_instance_valid(recipienteCaixas):
		return

	recipienteCaixas = Node3D.new()
	recipienteCaixas.name = "CaixasEntregues"

	if marcadorMonte != null:
		marcadorMonte.add_child(recipienteCaixas)
		recipienteCaixas.transform = Transform3D.IDENTITY
	else:
		get_tree().current_scene.add_child(recipienteCaixas)
		recipienteCaixas.global_transform = global_transform


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("caixas_soltas"):
		return

	if marcadorMonte == null:
		push_error("ERRO: atribua o marcadorMonte!")
		return

	var mesh: MeshInstance3D = null

	for filho in body.get_children():
		if filho is MeshInstance3D:
			mesh = filho as MeshInstance3D
			break

	if mesh == null:
		print("ERRO: mesh da caixa não encontrada!")
		return

	criar_recipiente()

	# DEPOIS DAS 11 ENTREGAS:
	# Permite devolver caixas já entregues ao monte.
	if entregaCompleta:
		var indice := caixasEntregues.find(mesh)

		if indice >= 0:
			organizar_caixa_no_monte(mesh, indice)

			mesh.set_meta("entregue_na_area", true)
			mesh.set_meta("pode_ser_recolhida", true)

			if not mesh.is_in_group("caixas_entregues"):
				mesh.add_to_group("caixas_entregues")

			body.queue_free()

			print("Caixa devolvida ao monte: ", indice + 1)
		else:
			print("Essa caixa não faz parte do monte original.")

		return

	# ANTES DAS 11 ENTREGAS:
	# Impede contar a mesma caixa duas vezes.
	if caixasEntregues.has(mesh):
		return

	var numero := str(mesh.get_meta("numero_caixa", "??"))
	var endereco := str(mesh.get_meta("endereco_casa", "SEM DESTINO"))

	var indice := caixasEntregues.size()

	organizar_caixa_no_monte(mesh, indice)

	mesh.set_meta("entregue_na_area", true)
	mesh.set_meta("pode_ser_recolhida", false)

	if not mesh.is_in_group("caixas_entregues"):
		mesh.add_to_group("caixas_entregues")

	caixasEntregues.append(mesh)

	# Remove o corpo físico original.
	body.queue_free()

	print(
		"Caixa ", numero,
		" | Destino: ", endereco,
		" | Entregues: ", caixasEntregues.size(),
		"/", totalCaixasNecessarias
	)

	if caixasEntregues.size() >= totalCaixasNecessarias:
		Gobla.atividadeDahora = "EntregaCaixa"
		finalizar_entrega()


func organizar_caixa_no_monte(
	mesh: MeshInstance3D,
	indice: int
) -> void:
	mesh.reparent(recipienteCaixas, false)

	var colunas := maxi(caixasPorColuna, 1)
	var alturas := maxi(caixasDeAltura, 1)

	var coluna := indice % colunas
	var altura := (indice / colunas) % alturas
	var camada := indice / (colunas * alturas)

	mesh.position = Vector3(
		coluna * espacamentoX,
		altura * espacamentoY,
		camada * espacamentoZ
	)

	mesh.rotation_degrees = rotacaoCaixa
	mesh.scale = escalaCaixa


func finalizar_entrega() -> void:
	if entregaCompleta:
		return

	entregaCompleta = true

	# Libera permanentemente todas as caixas entregues.
	for caixa in caixasEntregues:
		if not is_instance_valid(caixa):
			continue

		caixa.set_meta("pode_ser_recolhida", true)

	print("TODAS AS CAIXAS FORAM ENTREGUES!")
	print("Monte liberado permanentemente!")

	# Avisa o sistema responsável por pegar e soltar caixas.
	if is_instance_valid(sistemaCaixas):
		sistemaCaixas.set_meta("todas_caixas_entregues", true)
		sistemaCaixas.set_meta("liberar_entregas", true)

		if sistemaCaixas.has_method("liberar_caixas_entregues"):
			sistemaCaixas.call("liberar_caixas_entregues")
	else:
		push_warning(
			"Arraste o nó do sistema de caixas para sistemaCaixas no Inspector."
		)
