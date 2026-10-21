extends Node3D

var estNaAre = false
@export var input_label2: Label3D
const CAIXAS = preload("res://cenas/models/caixas.tscn")
@export var ponto: Marker3D
@export var pontoDoPl: Marker3D
@export var player: CharacterBody3D
@export var dialogos: CanvasLayer 

var DialogCOnDebora: Dictionary = {
	0: {
		"dialog": "Opa! Sou o Marcos, vim entregar as encomendas dessa cidadinha. Pode mandar aí!",
		"title": "Marcos",
	},
	1: {
		"dialog": "Fechou, Marcos! Meu nome é Débora, prazer em conhecer você. Vão ser umas 40 caixas. Vou mandar de 10 em 10, beleza?",
		"title": "Débora",
	},
	2: {
		"dialog": "Fechou!",
		"title": "Marcos",
	}
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if estNaAre and Input.is_action_just_pressed("interagir") and Gobla.atividadeDahora == "PODEPEGARCAIXA" or Gobla.atividadeDahora == "CAIXASENTREGES" :
		dialogos.dialogDiarioAbri(DialogCOnDebora)
		var caixa = CAIXAS.instantiate()
		caixa.pontoCaixa = pontoDoPl
		caixa.rayJogador = player.ray_cast_3d
		ponto.add_child(caixa)
		


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		estNaAre = true
		if input_label2 and Gobla.atividadeDahora == "PODEPEGARCAIXA":
			input_label2.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		estNaAre = false
		if input_label2:
			input_label2.hide()
