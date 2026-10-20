extends Control

var itens: Array = ["casa a17", "casa b15", "casa c03", "casa c03", "casa c03"]
var marcados: Array = []
@export var info: RichTextLabel
@export var atividd: Label
@export var hora: Label


func _ready() -> void:
	info.bbcode_enabled = true
	_rebuild()

func _physics_process(delta: float) -> void:
	if Gobla.atividadeDahora == "PODEPEGARCAIXA":
		atividd.text = "var na agencia da feira livre"
		
	if Gobla.atividadeDahora == "NAOPODEPEGARCAIXA":
		atividd.text = "peger as caixas e coloque no carro"
		
	if Gobla.atividadeDahora == "ENTRAGACAIXAS":
		atividd.text = "Entrege todas as caixas no seu devido lugar"
		
	if Gobla.atividadeDahora == "CAIXASENTREGES":
		atividd.text = "VOLTE PARA AGENCIA E PEGER MAIS CAIXAS"
	if Gobla.atividadeDahora == "UTIMASHORA":
		atividd.text = "ENTREGE O MAXIMO DE CAIXAS E "

	if Input.is_action_just_pressed("interagir"):
		marcar(2)
	if Input.is_action_just_pressed("ui_up"):
		marcar(4)

func marcar(indexo: int):
	if not marcados.has(indexo):
		marcados.append(indexo)
	_rebuild()

func desmarcar(indexo: int):
	marcados.erase(indexo)
	_rebuild()

func _rebuild():
	var texto: String = ""
	for i in itens.size():
		if i > 0:
			texto += "\n"
		if marcados.has(i):
			texto += "[b][s]" + itens[i] + "[/s][/b]"
		else:
			texto += itens[i]
	info.text = texto   
