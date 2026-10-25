
extends Node3D

@export var qualPerson: String = "LUCIA"
@export var dialogos: CanvasLayer
@export var input_label: Label3D

var jogadorNaArea: bool = false
var podeConversar: bool = true
var desapareceu: bool = false


var DialogNPC_Nina: Dictionary = {
	0: {"title": "Nina", "dialog": "Moço! Você é o entregador novo?"},
	1: {"title": "Marcos", "dialog": "Sou eu. Tá esperando alguma encomenda?"},
	2: {"title": "Nina", "dialog": "Não! Eu queria saber se você conhece o homem que entregava caixas aqui antes."},
	3: {"title": "Marcos", "dialog": "Não conheço. Por quê?"},
	4: {"title": "Nina", "dialog": "Meu pai disse que ele desapareceu depois de trabalhar numa noite de Halloween."},
	5: {"title": "Marcos", "dialog": "Ah, para com isso, menina. Não vai me assustar com história de fantasma."}
}

var DialogNPC_Bia: Dictionary = {
	0: {"title": "Bia", "dialog": "Moço! Moço! Você está entregando caixas por toda a cidade?"},
	1: {"title": "Marcos", "dialog": "Estou sim. Ainda tenho bastante trabalho pela frente."},
	2: {"title": "Bia", "dialog": "Então você vai passar perto da floresta?"},
	3: {"title": "Marcos", "dialog": "que floresta menina está doida??"},
	4: {"title": "Bia", "dialog": "tenho certeza moço, olha pra cima tem uma grande floresta de doçes"},
	5: {"title": "Marcos", "dialog": "tá bom, vou acredida"},
	6: {"title": "Bia", "dialog": "ebaaaaaaa"},
}

var DialogNPC_Lucia: Dictionary = {
	0: {"title": "Lúcia", "dialog": "Boa noite! Você deve ser o Marcos, o novo entregador."},
	1: {"title": "Marcos", "dialog": "Sou eu mesmo. Como todo mundo já sabe meu nome?"},
	2: {"title": "Lúcia", "dialog": "Cidade pequena, meu querido. A gente fica sabendo das coisas."},
	3: {"title": "Marcos", "dialog": "É, parece que não existe segredo por aqui."},
	4: {"title": "Lúcia", "dialog": "Segredo existe, sim. Só não é todo mundo que gosta de falar deles."},
	5: {"title": "Marcos", "dialog": "Tá... agora fiquei curioso. Mas tenho entregas pra fazer."}
}

var DialogNPC_Julia: Dictionary = {
	0: {"title": "Júlia", "dialog": "Você escolheu logo o Halloween pra trabalhar? Meus pêsames!"},
	1: {"title": "Marcos", "dialog": "Nem me fala. Eu podia estar em casa comendo alguma coisa."},
	2: {"title": "Júlia", "dialog": "Pelo menos aproveita enquanto ainda tem movimento na cidade."},
	3: {"title": "Marcos", "dialog": "Por que todo mundo fala como se a cidade fosse ficar diferente depois?"},
	4: {"title": "Júlia", "dialog": "Porque depois de certa hora, as pessoas preferem ficar dentro de casa."},
	5: {"title": "Marcos", "dialog": "Bom, eu não tenho esse luxo. Tenho um monte de caixas esperando."}
}

var DialogNPC_Celeste: Dictionary = {
	0: {"title": "Celeste", "dialog": "Marcos... então você finalmente chegou."},
	1: {"title": "Marcos", "dialog": "A gente se conhece? Como sabe meu nome?"},
	2: {"title": "Celeste", "dialog": "Eu conheci o entregador que veio antes de você."},
	3: {"title": "Marcos", "dialog": "Sério? Sabe o que aconteceu com ele?"},
	4: {"title": "Celeste", "dialog": "Ele também dizia que só queria terminar as entregas e ir para casa."},
	5: {"title": "Marcos", "dialog": "Tá, isso não tem graça. O que aconteceu com ele?"},
	6: {"title": "Celeste", "dialog": "Se eu fosse você, não aceitaria entregar nenhuma caixa depois da meia-noite."}
}

var DialogNPC_Anselmo: Dictionary = {
	0: {"title": "Anselmo", "dialog": "Entregador novo, hein? Faz tempo que não vejo um por estas bandas."},
	1: {"title": "Marcos", "dialog": "Como assim? A cidade não recebe encomendas?"},
	2: {"title": "Anselmo", "dialog": "Recebe. Mas o último rapaz que fazia esse serviço nunca mais apareceu."},
	3: {"title": "Marcos", "dialog": "Já ouvi essa história duas vezes hoje. Ninguém sabe o que aconteceu?"},
	4: {"title": "Anselmo", "dialog": "Alguns sabem. Mas quem sabe aprendeu a ficar de boca fechada."},
	5: {"title": "Marcos", "dialog": "Ótimo. Uma cidade cheia de gente que fala por enigmas."}
}

var DialogNPC_Rafael: Dictionary = {
	0: {"title": "Rafael", "dialog": "Você está entregando aquelas caixas marrons?"},
	1: {"title": "Marcos", "dialog": "Sim. Tem alguma coisa errada com elas?"},
	2: {"title": "Rafael", "dialog": "Não sei. Uma dessas chegou aqui há anos, mas ninguém veio buscar."},
	3: {"title": "Marcos", "dialog": "E o que você fez com ela?"},
	4: {"title": "Rafael", "dialog": "Deixei no depósito. Um dia, ouvi alguém batendo por dentro."},
	5: {"title": "Marcos", "dialog": "Espera aí... batendo por dentro?!"},
	6: {"title": "Rafael", "dialog": "Esquece o que eu disse. Deve ter sido algum bicho."}
}

var DialogNPC_Davi: Dictionary = {
	0: {"title": "Davi", "dialog": "Você é o entregador? Recebemos reclamações de gente andando pela cidade tarde da noite."},
	1: {"title": "Marcos", "dialog": "Eu estou trabalhando, senhor. Só estou fazendo meu serviço."},
	2: {"title": "Davi", "dialog": "Então termine antes da meia-noite. Não é uma boa hora para ficar circulando."},
	3: {"title": "Marcos", "dialog": "Todo mundo fala dessa maldita meia-noite. O que acontece nessa hora?"},
	4: {"title": "Davi", "dialog": "Meu conselho é não descobrir."},
	5: {"title": "Marcos", "dialog": "Tá bom... mas, se acontecer alguma coisa, vou lembrar que o senhor não quis explicar."}
}


func _ready() -> void:
	if is_instance_valid(input_label):
		input_label.hide()


func _process(_delta: float) -> void:
	if desapareceu:
		return

	if (
		jogadorNaArea
		and Input.is_action_just_pressed("interagir")
		and podeConversar
	):
		iniciar_dialogo()


func iniciar_dialogo() -> void:
	if desapareceu:
		return

	if not is_instance_valid(dialogos):
		push_error("Configure a variável 'dialogos' no NPC: " + qualPerson)
		return

	var conversa: Dictionary = {}

	match qualPerson.to_upper():
		"LUCIA":
			conversa = DialogNPC_Lucia
		"BIA":
			conversa = DialogNPC_Bia
		"JULIA":
			conversa = DialogNPC_Julia
		"CELESTE":
			conversa = DialogNPC_Celeste
		"NINA":
			conversa = DialogNPC_Nina
		"ANSELMO":
			conversa = DialogNPC_Anselmo
		"RAFAEL":
			conversa = DialogNPC_Rafael
		"DAVI":
			conversa = DialogNPC_Davi
		_:
			push_warning("NPC sem diálogo configurado: " + qualPerson)
			return

	podeConversar = false
	dialogos.call("dialogDiarioAbri", conversa)

	await get_tree().create_timer(0.5).timeout

	if not desapareceu:
		podeConversar = true


func sumir() -> void:
	if desapareceu:
		return

	desapareceu = true
	jogadorNaArea = false
	podeConversar = false

	if is_instance_valid(input_label):
		input_label.hide()

	visible = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if desapareceu:
		return

	if body.is_in_group("player"):
		jogadorNaArea = true

		if is_instance_valid(input_label):
			input_label.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		jogadorNaArea = false

		if is_instance_valid(input_label):
			input_label.hide()
