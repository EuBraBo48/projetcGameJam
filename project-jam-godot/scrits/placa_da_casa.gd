
extends Node3D

@export var label_3d: Label3D
@export var numeroDaCasa: String

var estaNaAre: bool = false
var sistemaCaixas: Node = null


func _ready() -> void:
	if label_3d:
		label_3d.text = numeroDaCasa

	# Encontra automaticamente o sistema de caixas.
	sistemaCaixas = get_tree().get_first_node_in_group("sistema_caixas")

	if sistemaCaixas == null:
		push_error("ERRO: não encontrei o sistema_caixas!")


func _process(_delta: float) -> void:
	if estaNaAre and Input.is_action_just_pressed("interagir") and Gobla.atividadeDahora == "EntregaCaixa":
		verificar_caixa()


func verificar_caixa() -> void:
	if not is_instance_valid(sistemaCaixas):
		sistemaCaixas = get_tree().get_first_node_in_group("sistema_caixas")

	if sistemaCaixas == null:
		print("ERRO: sistema de caixas não encontrado!")
		return

	if not sistemaCaixas.get("caixaNaMao"):
		print("Você precisa estar com uma caixa na mão!")
		return

	var caixa = sistemaCaixas.get("caixaAtual")

	if caixa == null or not is_instance_valid(caixa):
		print("ERRO: nenhuma caixa válida na mão!")
		return

	var endereco := str(
		caixa.get_meta("endereco_casa", "SEM DESTINO")
	).strip_edges().to_upper()

	var casa := numeroDaCasa.strip_edges().to_upper()

	print("Endereço da caixa: ", endereco)
	print("Endereço da casa: ", casa)

	if endereco == casa:
		print("CAIXA CORRETA!")
	else:
		print("CAIXA ERRADA!")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaAre = true
		print("Entrou na área da casa: ", numeroDaCasa)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaAre = false
		print("Saiu da área da casa: ", numeroDaCasa)
