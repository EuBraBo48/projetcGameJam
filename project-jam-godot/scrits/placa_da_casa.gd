
extends Node3D

@export var label_3d: Label3D
@export var numeroDaCasa: String = "A12"
@export var hud: Control
@export var dialogos: Node

var estaNaAre: bool = false
var sistemaCaixas: Node = null
var processandoEntrega: bool = false
var dialogoJaChamado: bool = false


# =========================================================
# DIALOGOS - VILA CP
# =========================================================

var DialogCasaA11: Dictionary = {
	0: {"dialog": "Finalmente alguém apareceu. Você é o entregador novo?", "title": "Morador"},
	1: {"dialog": "Sou o Marcos. Vim trazer sua encomenda. Assina aqui pra mim?", "title": "Marcos"},
	2: {"dialog": "Claro. Só uma coisa: se ouvir alguém chamando seu nome durante a noite, não responda.", "title": "Morador"},
	3: {"dialog": "Como é que é? Isso é alguma brincadeira?", "title": "Marcos"},
	4: {"dialog": "Tomara que seja. Feliz Halloween, Marcos.", "title": "Morador"}
}

var DialogCasaA12: Dictionary = {
	0: {"dialog": "Boa noite! Você é o rapaz dos Correios?", "title": "Moradora"},
	1: {"dialog": "Infelizmente, sou eu. Marcos, entregador. Tem uma caixa pra você.", "title": "Marcos"},
	2: {"dialog": "Obrigada. Faz tempo que não vejo um entregador novo por aqui.", "title": "Moradora"},
	3: {"dialog": "Novo? Eu só quero terminar meu turno e ir embora.", "title": "Marcos"},
	4: {"dialog": "Então não demore. Vila CP fica diferente depois da meia-noite.", "title": "Moradora"}
}

var DialogCasaA17: Dictionary = {
	0: {"dialog": "A encomenda chegou? Pensei que os Correios tivessem esquecido de mim.", "title": "Morador"},
	1: {"dialog": "Esquecido nada. Tenho caixa demais pra entregar e pouca paciência pra isso.", "title": "Marcos"},
	2: {"dialog": "Você vai entender quando conhecer melhor essa cidade.", "title": "Morador"},
	3: {"dialog": "Todo mundo aqui fala como se eu estivesse entrando numa maldição.", "title": "Marcos"}
}

var DialogCasaB15: Dictionary = {
	0: {"dialog": "Você demorou. Eu estava esperando você desde cedo.", "title": "Morador"},
	1: {"dialog": "Desde cedo? Eu acabei de chegar nessa cidade!", "title": "Marcos"},
	2: {"dialog": "Engraçado... A carta dizia que você chegaria hoje, no Halloween.", "title": "Morador"},
	3: {"dialog": "Carta? Eu só recebi uma rota de entregas da agência.", "title": "Marcos"}
}

var DialogCasaC03: Dictionary = {
	0: {"dialog": "Mais uma caixa? Deixe ali perto da porta, por favor.", "title": "Moradora"},
	1: {"dialog": "Mais uma? Essa é a primeira que estou entregando aqui.", "title": "Marcos"},
	2: {"dialog": "A primeira pra você, talvez. Para esta casa, já perdi a conta.", "title": "Moradora"},
	3: {"dialog": "Tá bom... Eu não ganho o suficiente pra discutir com cliente.", "title": "Marcos"}
}

var DialogCasaC02: Dictionary = {
	0: {"dialog": "Você veio sozinho de fora?", "title": "Morador"},
	1: {"dialog": "Vim. Por quê?", "title": "Marcos"},
	2: {"dialog": "Porque ninguém daqui aceitaria fazer entregas nesta noite.", "title": "Morador"},
	3: {"dialog": "Devia ter perguntado isso antes de aceitar o emprego.", "title": "Marcos"}
}

var DialogCasaC04: Dictionary = {
	0: {"dialog": "Entre... Quer dizer, não! Deixe a caixa na porta.", "title": "Moradora"},
	1: {"dialog": "Ué, senhora, decidiu isso agora?", "title": "Marcos"},
	2: {"dialog": "Ouvi passos dentro de casa. Mas moro sozinha.", "title": "Moradora"},
	3: {"dialog": "Olha, eu só entrego encomendas. Não sou investigador.", "title": "Marcos"}
}

var DialogCasaA13: Dictionary = {
	0: {"dialog": "Você conhece o antigo carteiro desta região?", "title": "Morador"},
	1: {"dialog": "Não. Comecei hoje. Aconteceu alguma coisa com ele?", "title": "Marcos"},
	2: {"dialog": "Ele entregou todas as caixas... menos uma.", "title": "Morador"},
	3: {"dialog": "E o que aconteceu com ele?", "title": "Marcos"},
	4: {"dialog": "Foi a última vez que alguém o viu.", "title": "Morador"}
}

var DialogCasaB14: Dictionary = {
	0: {"dialog": "A agência mandou você mesmo?", "title": "Moradora"},
	1: {"dialog": "Tem outro Marcos entregando caixas por aqui?", "title": "Marcos"},
	2: {"dialog": "Não brinque com isso. O nome no aviso era exatamente o seu.", "title": "Moradora"},
	3: {"dialog": "Que aviso? Ninguém me mostrou aviso nenhum!", "title": "Marcos"}
}

var DialogCasaA18: Dictionary = {
	0: {"dialog": "Coloque a caixa no chão e vá embora imediatamente.", "title": "Morador"},
	1: {"dialog": "Calma! Eu só preciso confirmar a entrega.", "title": "Marcos"},
	2: {"dialog": "Você não ouviu o sino da igreja?", "title": "Morador"},
	3: {"dialog": "Não ouvi sino nenhum.", "title": "Marcos"},
	4: {"dialog": "Então ainda dá tempo. Vá embora antes que toque.", "title": "Morador"}
}

var DialogCasaC01: Dictionary = {
	0: {"dialog": "Você está fazendo entregas em todas as ruas?", "title": "Moradora"},
	1: {"dialog": "É o trabalho. Ainda faltam muitas caixas.", "title": "Marcos"},
	2: {"dialog": "Tome cuidado com as ruas sem iluminação. Elas nem sempre levam ao mesmo lugar.", "title": "Moradora"},
	3: {"dialog": "Como assim? Rua é rua, senhora!", "title": "Marcos"}
}

var DialogCasaB11: Dictionary = {
	0: {"dialog": "A encomenda é minha, mas não fui eu quem pediu.", "title": "Morador"},
	1: {"dialog": "Como assim? Está com seu nome e endereço.", "title": "Marcos"},
	2: {"dialog": "Eu não faço pedidos desde que minha família foi embora daqui.", "title": "Morador"},
	3: {"dialog": "Talvez seja um erro da agência. Vou continuar minha rota.", "title": "Marcos"}
}

var DialogCasaF12: Dictionary = {
	0: {"dialog": "Você chegou à rua F. Achei que não teria coragem.", "title": "Moradora"},
	1: {"dialog": "Coragem? Eu só estou trabalhando!", "title": "Marcos"},
	2: {"dialog": "Foi o que o último entregador disse.", "title": "Moradora"},
	3: {"dialog": "Pronto. Já entendi que ninguém aqui sabe conversar normalmente.", "title": "Marcos"}
}

var DialogCasaF17: Dictionary = {
	0: {"dialog": "Você trouxe a caixa fechada?", "title": "Morador"},
	1: {"dialog": "Claro. Eu não abro encomendas dos outros.", "title": "Marcos"},
	2: {"dialog": "Ótimo. Se encontrar uma caixa aberta por aí, não olhe dentro.", "title": "Morador"},
	3: {"dialog": "Vocês combinaram de me assustar hoje? Só pode!", "title": "Marcos"}
}

var DialogCasaF15: Dictionary = {
	0: {"dialog": "A cidade parece normal para você?", "title": "Moradora"},
	1: {"dialog": "Não muito, mas já trabalhei em lugares piores.", "title": "Marcos"},
	2: {"dialog": "Então ainda não percebeu que os relógios daqui estão parados?", "title": "Moradora"},
	3: {"dialog": "O meu celular está funcionando. Deve ser problema dos relógios.", "title": "Marcos"}
}

var DialogCasaF03: Dictionary = {
	0: {"dialog": "A agência finalmente mandou a encomenda.", "title": "Morador"},
	1: {"dialog": "Finalmente? O senhor pediu faz muito tempo?", "title": "Marcos"},
	2: {"dialog": "No papel, ela foi enviada há treze anos.", "title": "Morador"},
	3: {"dialog": "Treze anos?! Isso é impossível!", "title": "Marcos"}
}

var DialogCasaC00: Dictionary = {
	0: {"dialog": "Você não deveria ter recebido essa rota.", "title": "Morador"},
	1: {"dialog": "Foi a própria agência que me mandou pra cá.", "title": "Marcos"},
	2: {"dialog": "A agência recebe os pedidos. Mas nem sempre é ela que escolhe o entregador.", "title": "Morador"},
	3: {"dialog": "Essa conversa está ficando esquisita demais.", "title": "Marcos"}
}

var DialogCasaC12: Dictionary = {
	0: {"dialog": "Você já passou pela praça central?", "title": "Moradora"},
	1: {"dialog": "Ainda não. Tenho uma lista enorme de entregas.", "title": "Marcos"},
	2: {"dialog": "Se passar por lá, não conte as pessoas reunidas perto da igreja.", "title": "Moradora"},
	3: {"dialog": "Agora até contar pessoas é proibido?", "title": "Marcos"}
}

var DialogCasaA15: Dictionary = {
	0: {"dialog": "Você sabe por que todas as encomendas chegaram hoje?", "title": "Morador"},
	1: {"dialog": "A agência juntou tudo e me mandou entregar.", "title": "Marcos"},
	2: {"dialog": "Todas têm a mesma data no remetente. Trinta e um de outubro.", "title": "Morador"},
	3: {"dialog": "É Halloween. Deve ser alguma coincidência.", "title": "Marcos"}
}

var DialogCasaB08: Dictionary = {
	0: {"dialog": "Não abra a porta para ninguém que não tenha uma encomenda.", "title": "Moradora"},
	1: {"dialog": "Mas eu sou o entregador!", "title": "Marcos"},
	2: {"dialog": "Eu sei. Estou avisando sobre quem pode vir depois de você.", "title": "Moradora"},
	3: {"dialog": "Certo... Vou fingir que isso é normal.", "title": "Marcos"}
}

var DialogCasaA20: Dictionary = {
	0: {"dialog": "Você encontrou alguma caixa sem endereço na sua rota?", "title": "Morador"},
	1: {"dialog": "Não. Todas têm destino e identificação.", "title": "Marcos"},
	2: {"dialog": "Se encontrar uma com seu nome, não entregue a ninguém.", "title": "Morador"},
	3: {"dialog": "Por que teria uma encomenda com meu nome?", "title": "Marcos"}
}

var DialogCasaC06: Dictionary = {
	0: {"dialog": "Você parece cansado, Marcos.", "title": "Moradora"},
	1: {"dialog": "Ainda faltam caixas demais. Quero terminar logo.", "title": "Marcos"},
	2: {"dialog": "Aqui, quem termina todas as entregas costuma receber uma última visita.", "title": "Moradora"},
	3: {"dialog": "Visita de quem?", "title": "Marcos"},
	4: {"dialog": "Do dono da cidade.", "title": "Moradora"}
}

var DialogCasaB67: Dictionary = {
	0: {"dialog": "Esse número não existe nos mapas antigos.", "title": "Morador"},
	1: {"dialog": "Mas está na minha lista. B67.", "title": "Marcos"},
	2: {"dialog": "Então a cidade começou a mudar de novo.", "title": "Morador"},
	3: {"dialog": "A cidade muda? Que tipo de lugar é esse?", "title": "Marcos"}
}

var DialogCasaV12: Dictionary = {
	0: {"dialog": "Você chegou à Vila Velha. A partir daqui, não confie nas placas.", "title": "Moradora"},
	1: {"dialog": "Eu sigo os endereços da lista, senhora.", "title": "Marcos"},
	2: {"dialog": "É por isso que estou preocupada.", "title": "Moradora"},
	3: {"dialog": "Isso não faz sentido nenhum...", "title": "Marcos"}
}

var DialogCasaV17: Dictionary = {
	0: {"dialog": "Você está atrasado para a última entrega.", "title": "Morador"},
	1: {"dialog": "Ainda tenho várias casas pela frente!", "title": "Marcos"},
	2: {"dialog": "Para você, talvez. Para esta cidade, a noite já está acabando.", "title": "Morador"},
	3: {"dialog": "Meu relógio diz que ainda é cedo.", "title": "Marcos"}
}

var DialogCasaV15: Dictionary = {
	0: {"dialog": "Quantas caixas você já entregou?", "title": "Moradora"},
	1: {"dialog": "Não sei de cabeça. Por quê?", "title": "Marcos"},
	2: {"dialog": "Porque cada caixa entregue fecha uma porta. E abre outra.", "title": "Moradora"},
	3: {"dialog": "Eu só quero receber meu salário no fim do mês.", "title": "Marcos"}
}

var DialogCasaV03: Dictionary = {
	0: {"dialog": "Então você é o Marcos.", "title": "Morador"},
	1: {"dialog": "Todo mundo nessa cidade sabe meu nome agora?", "title": "Marcos"},
	2: {"dialog": "A última caixa já está esperando por você.", "title": "Morador"},
	3: {"dialog": "Última caixa? Ainda tenho entregas na lista!", "title": "Marcos"},
	4: {"dialog": "Confira a lista novamente. Algumas entregas não aparecem até a hora certa.", "title": "Morador"}
}


# =========================================================
# INICIALIZACAO
# =========================================================

func _ready() -> void:
	if is_instance_valid(label_3d):
		label_3d.text = numeroDaCasa

	sistemaCaixas = get_tree().get_first_node_in_group("sistema_caixas")

	if sistemaCaixas == null:
		push_error("ERRO: não encontrei o sistema_caixas!")

	if not is_instance_valid(dialogos):
		push_warning("Arraste o nó de diálogos para o Inspector da casa.")


func _process(_delta: float) -> void:
	if estaNaAre and Input.is_action_just_pressed("interagir") and (Gobla.atividadeDahora == "ENTRAGACAIXAS" or Gobla.atividadeDahora == "UTIMASHORA"):
		verificar_caixa()


# =========================================================
# ESCOLHER O DIALOGO
# =========================================================

func chamar_dialogo_da_casa(casa: String) -> void:
	if not is_instance_valid(dialogos):
		push_error("ERRO: o nó de diálogos não foi configurado!")
		return

	var endereco := casa.strip_edges().to_upper()
	var dialogo: Dictionary = {}

	match endereco:
		"A11": dialogo = DialogCasaA11
		"A12": dialogo = DialogCasaA12
		"A17": dialogo = DialogCasaA17
		"B15": dialogo = DialogCasaB15
		"C03": dialogo = DialogCasaC03
		"C02": dialogo = DialogCasaC02
		"C04": dialogo = DialogCasaC04
		"A13": dialogo = DialogCasaA13
		"B14": dialogo = DialogCasaB14
		"A18": dialogo = DialogCasaA18
		"C01": dialogo = DialogCasaC01
		"B11": dialogo = DialogCasaB11
		"F12": dialogo = DialogCasaF12
		"F17": dialogo = DialogCasaF17
		"F15": dialogo = DialogCasaF15
		"F03": dialogo = DialogCasaF03
		"C00": dialogo = DialogCasaC00
		"C12": dialogo = DialogCasaC12
		"A15": dialogo = DialogCasaA15
		"B08": dialogo = DialogCasaB08
		"A20": dialogo = DialogCasaA20
		"C06": dialogo = DialogCasaC06
		"B67": dialogo = DialogCasaB67
		"V12": dialogo = DialogCasaV12
		"V17": dialogo = DialogCasaV17
		"V15": dialogo = DialogCasaV15
		"V03": dialogo = DialogCasaV03
		_:
			push_warning("Não existe diálogo para a casa " + endereco)
			return

	if dialogos.has_method("dialogDiarioAbri"):
		dialogos.call("dialogDiarioAbri", dialogo)
	else:
		push_error("O nó de diálogos não possui dialogDiarioAbri()!")


# =========================================================
# VERIFICAR E ENTREGAR A CAIXA
# =========================================================

func verificar_caixa() -> void:
	if processandoEntrega:
		return

	if not is_instance_valid(sistemaCaixas):
		sistemaCaixas = get_tree().get_first_node_in_group("sistema_caixas")

	if not is_instance_valid(sistemaCaixas):
		print("ERRO: sistema de caixas não encontrado!")
		return

	if not bool(sistemaCaixas.get("caixaNaMao")):
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

	if endereco != casa:
		print("CAIXA ERRADA! Esta caixa é para ", endereco)
		return

	processandoEntrega = true

	# Inicia o diálogo específico da casa.
	if not dialogoJaChamado:
		chamar_dialogo_da_casa(casa)
		dialogoJaChamado = true

	print("CAIXA CERTA! Entrega realizada na casa ", casa)

	# Limpa a referência da caixa na mão.
	sistemaCaixas.set("caixaAtual", null)
	sistemaCaixas.set("caixaNaMao", false)

	var fundo = sistemaCaixas.get("fundoDo")
	if fundo != null:
		fundo.hide()

	# Atualiza a HUD.
	if is_instance_valid(hud) and hud.has_method("registrar_entrega"):
		hud.call("registrar_entrega", casa)

	# Registra a entrega no sistema de caixas.
	if sistemaCaixas.has_method("registrar_entrega_correta"):
		sistemaCaixas.call("registrar_entrega_correta", casa)
	else:
		push_error(
			"Falta registrar_entrega_correta() no sistema de caixas!"
		)

	# Remove somente a caixa correta.
	caixa.queue_free()

	processandoEntrega = false


# =========================================================
# AREA DA CASA
# =========================================================

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaAre = true
		print("Entrou na área da casa: ", numeroDaCasa)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estaNaAre = false
		print("Saiu da área da casa: ", numeroDaCasa)
