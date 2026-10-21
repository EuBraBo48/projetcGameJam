
extends Control

var itens: Array[String] = [
	"Casa A12",
	"Casa A17",
	"Casa B15",
	"Casa C03",
	"Casa C02",
	"Casa C04",
	"Casa A13",
	"Casa B14",
	"Casa A18",
	"Casa C01",
	"Casa B11",
	"Casa F12",
	"Casa F17",
	"Casa F15",
	"Casa F03",
	"Casa C00",
	"Casa C12",
	"Casa A15",
	"Casa B08",
	"Casa A20",
	"Casa C06",
	"Casa B67",
	"Casa V12",
	"Casa V17",
	"Casa V15",
	"Casa V03"
]

var marcados: Array[int] = []

@export var info: RichTextLabel
@export var atividd: Label
@export var hora: Label
@export var menu_com_listagem: Control


# Relógio do jogo: começa às 18:00.
var hora_jogo: int = 18
var minuto_jogo: int = 0
var tempo_acumulado: float = 0.0

const SEGUNDOS_POR_HORA: float = 60.0


func _ready() -> void:
	if is_instance_valid(menu_com_listagem):
		menu_com_listagem.visible = false
	if info:
		info.bbcode_enabled = true

	atualizar_hora()
	_rebuild()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("listra"):
		if is_instance_valid(menu_com_listagem):
			menu_com_listagem.visible = not menu_com_listagem.visible
			
	tempo_acumulado += delta

	while tempo_acumulado >= SEGUNDOS_POR_HORA:
		tempo_acumulado -= SEGUNDOS_POR_HORA
		hora_jogo += 1

		if hora_jogo >= 24:
			hora_jogo = 0

		atualizar_hora()

	if not is_instance_valid(atividd):
		return

	match Gobla.atividadeDahora:
		"PODEPEGARCAIXA":
			atividd.text = "Ir na agência da feira livre"

		"NAOPODEPEGARCAIXA":
			atividd.text = "Pegar as caixas e colocar no carro"

		"ENTRAGACAIXAS":
			atividd.text = "Entregar todas as caixas no seu devido lugar"

		"CAIXASENTREGES":
			atividd.text = "Voltar para a agência e pegar mais caixas"

		"UTIMASHORA":
			atividd.text = "Entregar o máximo de caixas e sair vazado"


func atualizar_hora() -> void:
	if is_instance_valid(hora):
		hora.text = "%02d:%02d" % [hora_jogo, minuto_jogo]


# Chamado pelo script da casa quando uma entrega está correta.
func registrar_entrega(endereco: String) -> void:
	var destino := endereco.strip_edges().to_upper()

	for i in range(itens.size()):
		var endereco_item := itens[i].replace("Casa ", "").strip_edges().to_upper()

		if endereco_item == destino and not marcados.has(i):
			marcados.append(i)
			_rebuild()
			print("HUD: entrega marcada - ", itens[i])
			return

	print("HUD: não há entrega pendente para ", destino)


func marcar(indexo: int) -> void:
	if indexo >= 0 and indexo < itens.size() and not marcados.has(indexo):
		marcados.append(indexo)

	_rebuild()


func desmarcar(indexo: int) -> void:
	marcados.erase(indexo)
	_rebuild()


func _rebuild() -> void:
	if not is_instance_valid(info):
		return

	var texto: String = ""

	for i in range(itens.size()):
		if i > 0:
			texto += "\n"

		if marcados.has(i):
			texto += "[b][s]" + itens[i] + "[/s][/b]"
		else:
			texto += itens[i]

	info.text = texto
