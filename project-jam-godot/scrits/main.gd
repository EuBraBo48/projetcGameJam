
extends Node3D

var estNaAre: bool = false

@export var input_label2: Label3D
const CAIXAS = preload("res://cenas/models/caixas.tscn")

@export var ponto: Marker3D
@export var pontoDoPl: Marker3D
@export var player: CharacterBody3D
@export var dialogos: CanvasLayer

var quantidadeDeVezes: int = 0


var DialogMarcosCaixas1: Dictionary = {
	0: {
		"dialog": "Opa! Sou o Marcos, vim entregar as encomendas dessa cidadinha. Pode mandar aí!",
		"title": "Marcos"
	},
	1: {
		"dialog": "Fechou, Marcos! Meu nome é Débora, prazer em conhecer você. Vão ser umas 40 caixas. Vou mandar de 10 em 10, beleza?",
		"title": "Débora"
	},
	2: {
		"dialog": "Fechou! Bora terminar isso logo. Ainda quero aproveitar um pouco do Halloween.",
		"title": "Marcos"
	}
}


# SEGUNDA VEZ — Marcos volta para buscar mais caixas.
var DialogMarcosCaixas2: Dictionary = {
	0: {
		"dialog": "Opa, voltei! As primeiras caixas já estão comigo. Manda mais dez aí, Débora.",
		"title": "Marcos"
	},
	1: {
		"dialog": "Já voltou? Beleza! Aqui estão mais dez. E cuidado com algumas ruas, tá ficando tarde.",
		"title": "Débora"
	},
	2: {
		"dialog": "Cuidado com as ruas? Como assim? Tem alguma coisa acontecendo por aqui?",
		"title": "Marcos"
	},
	3: {
		"dialog": "Ah, nada demais! Só estou dizendo pra você ficar atento. Boa sorte com as entregas!",
		"title": "Débora"
	}
}


# TERCEIRA VEZ — Débora parece estar escondendo alguma coisa.
var DialogMarcosCaixas3: Dictionary = {
	0: {
		"dialog": "Débora, voltei de novo. Cara, ainda tem muita caixa pra entregar...",
		"title": "Marcos"
	},
	1: {
		"dialog": "Aqui estão mais dez, Marcos. Você está indo muito bem!",
		"title": "Débora"
	},
	2: {
		"dialog": "Você parece estar com pressa de me mandar embora. Tem certeza de que está tudo bem nessa cidade?",
		"title": "Marcos"
	},
	3: {
		"dialog": "Claro que está! Só termine as entregas antes que fique tarde demais, tá bom?",
		"title": "Débora"
	},
	4: {
		"dialog": "Tá... isso foi meio estranho. Enfim, vamos trabalhar.",
		"title": "Marcos"
	}
}

func _process(_delta: float) -> void:
	if (
		estNaAre
		and Input.is_action_just_pressed("interagir")
		and (
			Gobla.atividadeDahora == "PODEPEGARCAIXA"
			or Gobla.atividadeDahora == "CAIXASENTREGES"
		)
	):
		pegar_novas_caixas()


func pegar_novas_caixas() -> void:
	if not is_instance_valid(ponto):
		push_error("O ponto das caixas não foi configurado!")
		return

	if not is_instance_valid(pontoDoPl):
		push_error("O ponto de segurar as caixas não foi configurado!")
		return

	if not is_instance_valid(player):
		push_error("O jogador não foi configurado!")
		return

	if not is_instance_valid(dialogos):
		push_error("O nó de diálogos não foi configurado!")
		return

	# Escolhe o diálogo conforme as vezes que voltou à agência.
	if quantidadeDeVezes == 0:
		dialogos.dialogDiarioAbri(DialogMarcosCaixas1)
	elif quantidadeDeVezes == 1:
		dialogos.dialogDiarioAbri(DialogMarcosCaixas2)
	else:
		dialogos.dialogDiarioAbri(DialogMarcosCaixas3)

	quantidadeDeVezes += 1

	# Cria as caixas como no seu código original.
	var caixa = CAIXAS.instantiate()
	caixa.pontoCaixa = pontoDoPl
	caixa.rayJogador = player.ray_cast_3d
	ponto.add_child(caixa)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estNaAre = true

		if input_label2 and (
			Gobla.atividadeDahora == "PODEPEGARCAIXA"
			or Gobla.atividadeDahora == "CAIXASENTREGES"
		):
			input_label2.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estNaAre = false

		if input_label2:
			input_label2.hide()
