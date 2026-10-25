
extends CanvasLayer

const DIALOG_SCREEEN: PackedScene = preload("res://cenas/dialog.tscn")

@export_category("Objects")
@export var hud: CanvasLayer = null

var DialogChefeDia1: Dictionary = {
	0: {
		"dialog": "PORRA! Por que diabos eu tenho que trabalhar logo no Halloween? Que merda! Essa agência dos Correios só quer o mal do cara!",
		"title": "Marcos",
	},
	1: {
		"dialog": "Mas não é como se eu pudesse recusar esse trabalho. Então, só vou entrar no carro, pegar essas caixas e seguir com a minha vida.",
		"title": "Marcos",
	},
	2: {
		"dialog": "E lá vou eu entregar caixas nessa tal de Vila CP. É uma cidadinha no interior do Nordeste. Não tenho boas lembranças de lá, mas, enfim... É só fazer as entregas e pronto.",
		"title": "Marcos",
	},
	3: {
		"dialog": "Tutorial: use WASD para se movimentar. Para entrar no carro, abrir a porta e pegar as caixas, aperte E. As missões estão na parte de cima da tela.",
		"title": "Tutorial",
	},
	4: {
		"dialog": "Para conferir quantas caixas ainda faltam entregar, aperte R. Para soltar ou largar um objeto, aperte Q.",
		"title": "Tutorial",
	},
	5: {
		"dialog": "Agora vai lá e faça uma boa entrega. Feliz Halloween... e boa sorte em Vila CP!",
		"title": "Tutorial",
	}
}


# NOVO DIÁLOGO: quando Marcos morre
var DialogMorte: Dictionary = {
	0: {
		"dialog": "Ah, não... Não, não, não! Que porra aconteceu comigo?!",
		"title": "Marcos",
	},
	1: {
		"dialog": "Eu só vim fazer umas entregas. Umas caixas! Era só isso que eu precisava fazer!",
		"title": "Marcos",
	},
	2: {
		"dialog": "Mas é claro... Tinha que ser logo no Halloween. Eu devia ter ficado em casa.",
		"title": "Marcos",
	},
	3: {
		"dialog": "Que lugar é esse? Por que parece que tem alguma coisa errada com essa cidade?",
		"title": "Marcos",
	},
	4: {
		"dialog": "Seja lá o que estiver acontecendo aqui... Eu preciso descobrir como sair de Vila CP.",
		"title": "Marcos",
	}
}


func _ready() -> void:
	if Gobla.morreu:
		$"../loginha".show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dialogDiarioAbri(DialogMorte)
	else:
		
		dialogDiarioAbri(DialogChefeDia1)


func dialogDiarioAbri(nome: Dictionary) -> void:
	var dialog: DialogScren = DIALOG_SCREEEN.instantiate()
	dialog.data = nome

	get_tree().paused = true
	hud.add_child(dialog)
