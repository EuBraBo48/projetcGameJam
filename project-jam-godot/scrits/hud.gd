
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
@export var contagem_regressiva: Label
@export var menu_com_listagem: Control
@export var dialogos: Node
@export var npcs_para_sumir: Array[Node3D] = []
@export var ambiente: WorldEnvironment
@export var jumpscare: PackedScene

var npcs_sumiram: bool = false

var hora_jogo: int = 21
var minuto_jogo: int = 0
var tempo_acumulado: float = 0.0

const SEGUNDOS_POR_HORA: float = 60.0

# Contagem regressiva iniciada às 22:00
var contagem_ativa: bool = false
var segundos_restantes: int = 60
var tempo_contagem: float = 0.0
var contagem_finalizada: bool = false

var dialogos_horarios_exibidos: Array[int] = []


var DialogMarcos20: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Beleza... mais algumas entregas e eu termino isso. Mas que cidade esquisita. Parece que não tem ninguém na rua hoje."
	},
	1: {
		"title": "Marcos",
		"dialog": "É Halloween, eu sei... mas nem parece que tem gente morando aqui. E por que diabos aquelas casas estão todas com as luzes apagadas?"
	},
	2: {
		"title": "Marcos",
		"dialog": "Tanto faz. Eu só preciso terminar o serviço, receber meu dinheiro e cair fora dessa Vila CP."
	}
}


var DialogMarcos22: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Ué... cadê todo mundo? Mais cedo tinha gente andando por essas ruas."
	},
	1: {
		"title": "Marcos",
		"dialog": "As lojas estão fechadas, as ruas tão vazias... até parece que a cidade inteira resolveu ir dormir ao mesmo tempo."
	},
	2: {
		"title": "Marcos",
		"dialog": "Deve ser por causa do Halloween. Talvez tenham ido pra alguma festa ou se reunido em casa. Sei lá."
	},
	3: {
		"title": "Marcos",
		"dialog": "Mas que estranho... nem um carro passando. Bom, não é problema meu. Tenho caixas pra entregar."
	}
}


var DialogMarcos00: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Meia-noite... e continua todo mundo sumido. Não vi uma alma viva faz um tempão."
	},
	1: {
		"title": "Marcos",
		"dialog": "Eu entendo que é Halloween, mas a cidade inteira não pode ter desaparecido assim do nada."
	},
	2: {
		"title": "Marcos",
		"dialog": "Peraí... eu tô ouvindo alguma coisa? Tem alguém aí?"
	},
	3: {
		"title": "Marcos",
		"dialog": "Droga, deve ser só o vento. Vou terminar essas entregas e sair daqui. Não quero passar mais uma noite nessa cidade."
	}
}


func _ready() -> void:
	if is_instance_valid(menu_com_listagem):
		menu_com_listagem.visible = false

	if is_instance_valid(info):
		info.bbcode_enabled = true

	if is_instance_valid(contagem_regressiva):
		contagem_regressiva.hide()
		contagem_regressiva.text = "60"

	atualizar_hora()
	_rebuild()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("listra"):
		if is_instance_valid(menu_com_listagem):
			menu_com_listagem.visible = not menu_com_listagem.visible

	# Relógio normal do jogo
	tempo_acumulado += delta

	while tempo_acumulado >= SEGUNDOS_POR_HORA:
		tempo_acumulado -= SEGUNDOS_POR_HORA
		minuto_jogo = 0
		hora_jogo += 1

		if hora_jogo >= 24:
			hora_jogo = 0

		atualizar_hora()
		verificar_dialogo_horario()

	# Contagem regressiva: um segundo real por segundo
	if contagem_ativa and not contagem_finalizada:
		tempo_contagem += delta

		while tempo_contagem >= 1.0:
			tempo_contagem -= 1.0
			segundos_restantes -= 1

			if segundos_restantes <= 0:
				segundos_restantes = 0
				contagem_finalizada = true
				contagem_ativa = false

				if is_instance_valid(contagem_regressiva):
					contagem_regressiva.text = "0"

				if jumpscare != null:
					var cena_susto = jumpscare.instantiate()
					get_tree().root.add_child(cena_susto)

					if cena_susto.has_method("iniciar_susto"):
						cena_susto.iniciar_susto()
				else:
					push_warning("HUD: configure a cena Jumpscare no Inspector.")

				break

			atualizar_contagem()

	# Atualiza o objetivo da HUD
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


func verificar_dialogo_horario() -> void:
	if hora_jogo == 22:
		iniciar_ultima_hora()

	if not is_instance_valid(dialogos):
		push_warning("HUD: configure a variável 'dialogos'.")
		return

	match hora_jogo:
		20:
			chamar_dialogo_horario(20, DialogMarcos20)

		22:
			chamar_dialogo_horario(22, DialogMarcos22)

		0:
			chamar_dialogo_horario(0, DialogMarcos00)


func iniciar_ultima_hora() -> void:
	# Evita iniciar tudo novamente
	if contagem_ativa or contagem_finalizada:
		return

	print("HUD: começou a última etapa!")

	# Muda o objetivo global
	Gobla.atividadeDahora = "UTIMASHORA"

	# Faz todos os NPCs configurados desaparecerem
	sumir_npcs()

	# Esconde o relógio normal
	if is_instance_valid(hora):
		hora.hide()

	# Mostra a contagem regressiva
	segundos_restantes = 60
	tempo_contagem = 0.0
	contagem_ativa = true
	contagem_finalizada = false

	if is_instance_valid(contagem_regressiva):
		contagem_regressiva.text = "60"
		contagem_regressiva.show()

	# Escurece a imagem do jogo
	escurecer_ambiente()


func atualizar_contagem() -> void:
	if is_instance_valid(contagem_regressiva):
		contagem_regressiva.text = str(segundos_restantes)


func escurecer_ambiente() -> void:
	if not is_instance_valid(ambiente):
		push_warning("HUD: configure o WorldEnvironment na variável 'ambiente'.")
		return

	if not is_instance_valid(ambiente.environment):
		push_warning("HUD: o WorldEnvironment não tem um Environment configurado.")
		return

	ambiente.environment.adjustment_enabled = true
	ambiente.environment.adjustment_brightness = 0.55

	print("HUD: o ambiente ficou mais escuro!")


func sumir_npcs() -> void:
	if npcs_sumiram:
		return

	npcs_sumiram = true

	for npc in npcs_para_sumir:
		if is_instance_valid(npc):
			npc.call("sumir")

	print("HUD: todos os NPCs desapareceram às 22:00!")


func chamar_dialogo_horario(horario: int, nomeDoNegocio: Dictionary) -> void:
	if dialogos_horarios_exibidos.has(horario):
		return

	dialogos_horarios_exibidos.append(horario)

	if is_instance_valid(dialogos):
		dialogos.call("dialogDiarioAbri", nomeDoNegocio)


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
