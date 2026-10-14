extends Control
class_name DialogScren

var _speed: float = 0.03

var _id: int = 0
var data: Dictionary = {}

@export_category("Objects")
@export var _name: Label = null
@export var _texte: RichTextLabel = null


func _ready() -> void:
	_initialice_dialog()

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and _texte.visible_ratio <  1:
		_speed = 0.03
		return
	_speed = 0.03
	
	if Input.is_action_just_pressed("ui_accept"):
		_id += 1	
		if _id == data.size():
			queue_free()
			get_tree().paused = false
			return	
		_initialice_dialog()	

	
func _initialice_dialog() -> void:
	if data.has(_id):
		_name.text = data[_id]["title"]
		_texte.text = data[_id]["dialog"]
		_texte.visible_characters = 0
		
		while _texte.visible_ratio < 1:
			await get_tree().create_timer(_speed).timeout
			_texte.visible_characters += 1
