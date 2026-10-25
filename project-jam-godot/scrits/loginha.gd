
extends Control

@export var fundo_da_compra: ColorRect
@export var sprite_2d: Sprite2D
@export var _name: Label
@export var descrição: RichTextLabel
@export var compra: Button
@export var ponto: Label
@export var Rankponto: Label
@export var player: CharacterBody3D
@export var main: Node3D
@onready var check_box: CheckBox = $fundoDaCompra/CheckBox

var equipa: String = ""
var N: String = ""
var valor_atual: int = 0





func _process(_delta: float) -> void:
	if is_instance_valid(ponto):
		ponto.text = "pontos: " + str(Gobla.pontos)

	atualizar_ranking()


func atualizar_ranking() -> void:
	if not is_instance_valid(Rankponto):
		return

	if Gobla.ranking_partidas.is_empty():
		Rankponto.text = "RANKING\n\nNenhuma partida registrada ainda."
		return

	var texto: String = "RANKING — MELHORES TEMPOS\n\n"

	for i in range(Gobla.ranking_partidas.size()):
		var partida: Dictionary = Gobla.ranking_partidas[i]

		var tempo: int = int(partida["tempo"])
		var minutos: int = int(tempo / 60)
		var segundos: int = tempo % 60
		var caixas: int = int(partida["caixas"])

		var resultado: String
		if bool(partida["morreu"]):
			resultado = "Morreu"
		else:
			resultado = "Sobreviveu"

		texto += "%02d. %02d min %02d s | %d caixas | %s\n" % [
			i + 1,
			minutos,
			segundos,
			caixas,
			resultado
		]

	Rankponto.text = texto

func Compra(sprite: String, No: String, des: String, valo: int, equipamento: String) -> void:
	fundo_da_compra.show()

	sprite_2d.texture = load(sprite) as Texture2D
	_name.text = No
	descrição.text = des

	equipa = equipamento
	N = No
	valor_atual = valo

	atualizar_estado_compra()

	# Verifica o item realmente equipado no Gobla.
	var equipado: bool = false

	if equipa == "equipa":
		equipado = Gobla.mao_equipada == N
	else:
		equipado = Gobla.animal_selecionado == N

	# Atualiza a aparência sem disparar o sinal.
	check_box.set_pressed_no_signal(equipado)

func atualizar_estado_compra() -> void:
	var comprado: bool = Gobla.itens_comprados.get(N, false)

	if is_instance_valid(compra):
		if comprado:
			compra.text = "Comprado"
			compra.disabled = true
		else:
			compra.text = "Comprar (" + str(valor_atual) + " pontos)"
			compra.disabled = false

	var ponto_janela = get_node_or_null("fundoDaCompra/ponto")
	if ponto_janela is Label:
		ponto_janela.text = "pontos: " + str(Gobla.pontos)

	if is_instance_valid(ponto):
		ponto.text = "pontos: " + str(Gobla.pontos)


func _on_volta_pressed() -> void:
	fundo_da_compra.hide()


func _on_button_p_1_pressed() -> void:
	Compra(
		"res://models/FTS/p2.png",
		"Cachorro Olhudo",
		"Seus olhos enormes ajudam você a ganhar 1 minuto extra durante a perseguição! E por apenas 20 moedas, ele ainda fica de olho em tudo.",
		20,
		"Ajuda"
	)


func _on_button_p_2_pressed() -> void:
	Compra(
		"res://models/FTS/p1.png",
		"Bicho Azul",
		"Ele é azul. Muito azul. E ainda garante 2 minutos extras para você escapar das enrascadas. Tudo isso por apenas 50 moedas!",
		50,
		"Ajuda"
	)


func _on__pressed() -> void:
	Compra(
		"res://models/FTS/p3.png",
		"Gato JPG",
		"Um gato simplesmente incrível! Ele garante 30 segundos extras e custa apenas 15 moedas. Miau!",
		15,
		"Ajuda"
	)


func _on_button_p_4_pressed() -> void:
	Compra(
		"res://models/FTS/p4.png",
		"Pedrinha",
		"Pequena, adorável e surpreendentemente poderosa! Essa pedrinha garante incríveis 3 minutos extras. Só não pergunte como. Custa 100 moedas!",
		100,
		"Ajuda"
	)


func _on_button_p_5_pressed() -> void:
	Compra(
		"res://models/FTS/p5.png",
		"Robozinho",
		"Inteligente, tecnológico e cheio de recursos! Esse robozinho garante 5 minutos extras e entende bastante de IA. O problema? Ele custa salgados 200 moedas!",
		200,
		"Ajuda"
	)


func _on_buttonm_2_pressed() -> void:
	Compra(
		"res://models/FTS/m2.png",
		"Mão Normal",
		"Simples, clássica e sem frescura. Não oferece nenhuma vantagem especial, mas combina com qualquer situação. É puramente decorativa.",
		20,
		"equipa"
	)


func _on_buttonm_3_pressed() -> void:
	Compra(
		"res://models/FTS/m3.png",
		"Mão de Soldado",
		"Toda verdona e cheia de estilo! Perfeita para quem quer entrar em ação com um visual militar. Não oferece vantagens: é só pela aparência.",
		30,
		"equipa"
	)


func _on_buttonm_4_pressed() -> void:
	Compra(
		"res://models/FTS/m4.png",
		"Mão de Espadachim",
		"Discreta, elegante e muito bonita. Uma mão que passa aquela impressão de quem sabe o que está fazendo. É apenas decorativa.",
		100,
		"equipa"
	)


func _on_buttonm_5_pressed() -> void:
	Compra(
		"res://models/FTS/m5.png",
		"Mão CERRAR",
		"CUIDADO: ISSO CORTA! Uma das mãos mais estilosas e perigosas da coleção. Parece feita para quem não está de brincadeira. Apesar da aparência ameaçadora, é apenas decorativa.",
		150,
		"equipa"
	)


func _on_check_box_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		return

	if equipa == "equipa":
		if not Gobla.itens_comprados.get(N, false):
			print("LOJA: compre essa mão antes de equipar.")
			return

		player.m_1.hide()
		player.m_2.hide()
		player.m_3.hide()
		player.m_4.hide()
		player.m_5.hide()

		match N:
			"Mão Normal":
				player.m_1.show()
			"Mão de Soldado":
				player.m_2.show()
			"Mão de Espadachim":
				player.m_3.show()
			"Mão CERRAR":
				player.m_4.show()

		Gobla.mao_equipada = N
		print("LOJA: mão equipada: ", N)

	else:
		# Só permite selecionar animais já comprados.
		if not Gobla.itens_comprados.get(N, false):
			print("LOJA: compre o animal antes de selecioná-lo.")
			return

		if not is_instance_valid(main):
			push_warning("LOJA: configure o nó main no Inspector.")
			return



		match N:
			"Cachorro Olhudo":
				main.p_1.show()
				Gobla.tempo_extra_animal = 60

			"Bicho Azul":
				main.p_2.show()
				Gobla.tempo_extra_animal = 120

			"Gato JPG":
				main.p_3.show()
				Gobla.tempo_extra_animal = 30

			"Pedrinha":
				main.p_4.show()
				Gobla.tempo_extra_animal = 180

			"Robozinho":
				main.p_5.show()
				Gobla.tempo_extra_animal = 300

			_:
				return

		Gobla.animal_selecionado = N

		print("LOJA: animal selecionado: ", N)
		print("LOJA: bônus salvo: ", Gobla.tempo_extra_animal, " segundos")


func _on_compra_pressed() -> void:
	if N.is_empty():
		return

	if Gobla.itens_comprados.get(N, false):
		atualizar_estado_compra()
		return

	if Gobla.pontos < valor_atual:
		print("LOJA: pontos insuficientes para comprar ", N)
		return

	Gobla.pontos -= valor_atual
	Gobla.itens_comprados[N] = true

	print("LOJA: compra realizada: ", N)

	atualizar_estado_compra()


func _on_fecha_pressed() -> void:
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
