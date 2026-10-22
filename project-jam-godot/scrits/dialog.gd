
extends Control
class_name DialogScren

var _speed: float = 0.03
var _id: int = 0
var data: Dictionary = {}
var _escrevendo: bool = false
var _pular_texto: bool = false

@export_category("Objects")
@export var _name: Label = null
@export var _texte: RichTextLabel = null


func _ready() -> void:
	get_tree().paused = true
	_initialice_dialog()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if _escrevendo:
			# Primeiro aperto: mostra o texto inteiro rapidamente.
			_pular_texto = true
		else:
			# Próximo aperto: avança para o próximo diálogo.
			_id += 1

			if _id >= data.size():
				get_tree().paused = false
				queue_free()
				return

			_initialice_dialog()


func _initialice_dialog() -> void:
	if not data.has(_id):
		get_tree().paused = false
		queue_free()
		return

	_name.text = data[_id]["title"]
	_texte.text = data[_id]["dialog"]
	_texte.visible_characters = 0

	_escrevendo = true
	_pular_texto = false

	while _texte.visible_characters < _texte.get_total_character_count():
		if _pular_texto:
			_texte.visible_characters = -1
			break

		await get_tree().create_timer(_speed).timeout
		_texte.visible_characters += 1

	_escrevendo = false
