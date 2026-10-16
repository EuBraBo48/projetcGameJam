extends Control

var itens: Array = ["casa a17", "casa b15", "casa c03", "casa c03", "casa c03"]
var marcados: Array = []
@export var info: RichTextLabel

func _ready() -> void:
	info.bbcode_enabled = true
	_rebuild()

func _physics_process(delta: float) -> void:
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
