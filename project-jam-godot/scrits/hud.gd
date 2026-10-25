
extends Control

var itens: Array[String] = [
	"Casa A12", "Casa A17", "Casa B15", "Casa C03",
	"Casa C02", "Casa C04", "Casa A13", "Casa B14",
	"Casa A18", "Casa C01", "Casa B11", "Casa F12",
	"Casa F17", "Casa F15", "Casa F03", "Casa C00",
	"Casa C12", "Casa A15", "Casa B08", "Casa A20",
	"Casa C06", "Casa B67", "Casa V12", "Casa V17",
	"Casa V15", "Casa V03"
]

var marcados: Array[int] = []

@export var info: RichTextLabel
@export var atividd: Label
@export var hora: Label
@export var contagem_regressiva: Label
@export var menu_com_listagem: Control
@export var dialogos: Node
@export var npcs_para_sumir: Array[Node3D] = []
@export var ambiente: WorldEnvironment
@export var menu_morte: Control
@export var imagan: Sprite2D

@export_group("Jumpscare")
@export var jumpscare: PackedScene
@export var marcador_susto: Marker3D

var tempo_partida_segundos: float = 0.0
var partida_registrada: bool = false
var jogador_na_area_fuga: bool = false
var fuga_ativada: bool = false

var npcs_sumiram: bool = false
var jumpscare_criado: bool = false

var hora_jogo: int = 18
var minuto_jogo: int = 0
var tempo_acumulado: float = 0.0

const SEGUNDOS_POR_HORA: float = 100.0

var contagem_ativa: bool = false
var segundos_restantes: int = 60
var tempo_contagem: float = 0.0
var contagem_finalizada: bool = false

var dialogos_horarios_exibidos: Array[int] = []
var DialogFuga: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Ufa! Consegui sair de lá! Por pouco eu não fiquei preso naquela cidade maldita..."
	},
	1: {
		"title": "Marcos",
		"dialog": "Eu preciso ir embora dessa cidade. Depois de tudo que aconteceu, nunca mais quero voltar aqui."
	}
}

var DialogMarcos20: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Beleza... mais algumas entregas e eu termino isso. Mas que cidade esquisita. Parece que não tem ninguém na rua hoje."
	},
	1: {
		"title": "Marcos",
		"dialog": "É Halloween, eu sei... mas nem parece que tem gente morando aqui. E por que diabos aquelas casas estão todas com as luzes apagadas?"
	},
	2: {
		"title": "Marcos",
		"dialog": "Tanto faz. Eu só preciso terminar o serviço, receber meu dinheiro e cair fora dessa Vila CP."
	}
}

var DialogMarcos22: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Ué... cadê todo mundo? Mais cedo tinha gente andando por essas ruas."
	},
	1: {
		"title": "Marcos",
		"dialog": "As lojas estão fechadas, as ruas tão vazias... até parece que a cidade inteira resolveu ir dormir ao mesmo tempo."
	},
	2: {
		"title": "Marcos",
		"dialog": "Deve ser por causa do Halloween. Talvez tenham ido pra alguma festa ou se reunido em casa. Sei lá."
	},
	3: {
		"title": "Marcos",
		"dialog": "Mas que estranho... nem um carro passando. Bom, não é problema meu. Tenho caixas pra entregar."
	}
}

var DialogMarcos00: Dictionary = {
	0: {
		"title": "Marcos",
		"dialog": "Meia-noite... e continua todo mundo sumido. Não vi uma alma viva faz um tempão."
	},
	1: {
		"title": "Marcos",
		"dialog": "Eu entendo que é Halloween, mas a cidade inteira não pode ter desaparecido assim do nada."
	},
	2: {
		"title": "Marcos",
		"dialog": "Peraí... eu tô ouvindo alguma coisa? Tem alguém aí?"
	},
	3: {
		"title": "Marcos",
		"dialog": "Droga, deve ser só o vento. Vou terminar essas entregas e sair daqui. Não quero passar mais uma noite nessa cidade."
	}
}


func _ready() -> void:
	add_to_group("hud_entregas")

	# A HUD precisa continuar funcionando durante a pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS

	if is_instance_valid(menu_com_listagem):
		menu_com_listagem.visible = false

	if is_instance_valid(info):
		info.bbcode_enabled = true

	if is_instance_valid(contagem_regressiva):
		contagem_regressiva.hide()
		$FundoDaContage.hide()
		contagem_regressiva.text = "60"

	atualizar_hora()
	_rebuild()


func _process(delta: float) -> void:
	# O menu de pausa continua respondendo mesmo com o jogo pausado.
	if Input.is_action_just_pressed("pause") and Gobla.atividadeDahora != "UTIMASHORA":
		if $menu.visible:
			$menu.hide()
			get_tree().paused = false
			imagan.show()
			atividd.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			$menu.show()
			imagan.hide()
			atividd.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true

	# IMPORTANTE:
	# Se o jogo estiver pausado, nada abaixo avança.
	if get_tree().paused:
		return

	# Tempo total da partida.
	if not partida_registrada:
		tempo_partida_segundos += delta

	if jogador_na_area_fuga and not fuga_ativada:
		if Input.is_action_just_pressed("interagir"):
			if Gobla.atividadeDahora == "UTIMASHORA" and not contagem_finalizada and segundos_restantes > 0:
				fuga_ativada = true
				print("FUGA ATIVADA!")

				if is_instance_valid(dialogos):
					dialogos.call("dialogDiarioAbri", {
						0: {
							"title": "Marcos",
							"dialog": "Ufa! Consegui sair de lá! Por pouco eu não fiquei preso naquela cidade maldita..."
						},
						1: {
							"title": "Marcos",
							"dialog": "Preciso ir embora daqui. Nunca mais quero voltar a essa cidade!"
						}
					})

				await get_tree().create_timer(3.0).timeout

				# REGISTRAR O RESULTADO NO RANKING
				registrar_resultado_partida(false)

				Gobla.morreu = true
				Gobla.atividadeDahora = "PODEPEGARCAIXA"

				if is_instance_valid(ambiente) and is_instance_valid(ambiente.environment):
					ambiente.environment.adjustment_enabled = true
					ambiente.environment.adjustment_brightness = 1.0

				get_tree().change_scene_to_file("res://cenas/main.tscn")
	# Abre ou fecha a lista de entregas.
	if Input.is_action_just_pressed("listra"):
		if is_instance_valid(menu_com_listagem):
			menu_com_listagem.visible = not menu_com_listagem.visible

	# Relógio do jogo.
	tempo_acumulado += delta

	while tempo_acumulado >= SEGUNDOS_POR_HORA:
		tempo_acumulado -= SEGUNDOS_POR_HORA
		minuto_jogo = 0
		hora_jogo += 1

		if hora_jogo >= 24:
			hora_jogo = 0

		atualizar_hora()
		verificar_dialogo_horario()

	# Contagem regressiva da última hora.
	if contagem_ativa and not contagem_finalizada:
		tempo_contagem += delta

		while tempo_contagem >= 1.0:
			tempo_contagem -= 1.0
			segundos_restantes -= 1

			if segundos_restantes <= 0:
				segundos_restantes = 0
				contagem_finalizada = true
				contagem_ativa = false

				if is_instance_valid(contagem_regressiva):
					contagem_regressiva.text = "0"

				criar_jumpscare()
				break

			atualizar_contagem()

	if not is_instance_valid(atividd):
		return

	match Gobla.atividadeDahora:
		"PODEPEGARCAIXA":
			atividd.text = "Ir na agência da feira livre"
		"NAOPODEPEGARCAIXA":
			atividd.text = "Pegar as caixas e colocar no carro"
		"ENTRAGACAIXAS":
			atividd.text = "Entregar todas as caixas no seu devido lugar"
		"CAIXASENTREGES":
			atividd.text = "Voltar para a agência e pegar mais caixas"
		"UTIMASHORA":
			atividd.text = "Entregar o máximo de caixas e sair vazado"



# Recebe os endereços da remessa atual.
func definir_remessa(enderecos: Array[String]) -> void:
	itens.clear()
	marcados.clear()

	for endereco in enderecos:
		itens.append("Casa " + endereco)

	_rebuild()
	print("HUD: lista da remessa atualizada: ", itens.size(), " endereços")


func registrar_entrega(endereco: String) -> void:
	var destino := endereco.strip_edges().to_upper()

	for i in range(itens.size()):
		var endereco_item := itens[i].replace("Casa ", "").strip_edges().to_upper()

		if endereco_item == destino and not marcados.has(i):
			marcados.append(i)
			_rebuild()
			print("HUD: entrega marcada - ", itens[i])
			return

	print("HUD: não há entrega pendente para ", destino)


func marcar(indexo: int) -> void:
	if indexo >= 0 and indexo < itens.size() and not marcados.has(indexo):
		marcados.append(indexo)

	_rebuild()


func desmarcar(indexo: int) -> void:
	marcados.erase(indexo)
	_rebuild()


func _rebuild() -> void:
	if not is_instance_valid(info):
		return

	var texto: String = ""

	for i in range(itens.size()):
		if i > 0:
			texto += "\n"

		if marcados.has(i):
			texto += "[b][s]" + itens[i] + "[/s][/b]"
		else:
			texto += itens[i]

	info.text = texto


func atualizar_hora() -> void:
	if is_instance_valid(hora):
		hora.text = "%02d:%02d" % [hora_jogo, minuto_jogo]


func verificar_dialogo_horario() -> void:
	if hora_jogo == 23:
		iniciar_ultima_hora()

	if not is_instance_valid(dialogos):
		push_warning("HUD: configure a variável 'dialogos'.")
		return

	match hora_jogo:
		19:
			chamar_dialogo_horario(20, DialogMarcos20)
		21:
			chamar_dialogo_horario(22, DialogMarcos22)
		23:
			chamar_dialogo_horario(23, DialogMarcos00)


func iniciar_ultima_hora() -> void:
	if contagem_ativa or contagem_finalizada:
		return

	print("HUD: começou a última etapa!")
	Gobla.atividadeDahora = "UTIMASHORA"

	sumir_npcs()

	if is_instance_valid(hora):
		hora.hide()
		$FundoH.hide()
		$"../../AudioStreamPlayer".stop()
		$"../../AudioStreamPlayer2".play()

	# Bônus do animal em segundos.
	var bonus_animal: int = int(Gobla.tempo_extra_animal)

	# 60 segundos iniciais mais o bônus.
	segundos_restantes = 60 + bonus_animal

	tempo_contagem = 0.0
	contagem_ativa = true
	contagem_finalizada = false

	if is_instance_valid(contagem_regressiva):
		contagem_regressiva.text = str(segundos_restantes)
		contagem_regressiva.show()
		$FundoDaContage.show()

	escurecer_ambiente()

	print("HUD: animal selecionado: ", Gobla.animal_selecionado)
	print("HUD: bônus de tempo: ", bonus_animal, " segundos")
	print("HUD: tempo total para fugir: ", segundos_restantes, " segundos")


func atualizar_contagem() -> void:
	if is_instance_valid(contagem_regressiva):
		contagem_regressiva.text = str(segundos_restantes)


func escurecer_ambiente() -> void:
	if not is_instance_valid(ambiente):
		push_warning("HUD: configure o WorldEnvironment na variável 'ambiente'.")
		return

	if not is_instance_valid(ambiente.environment):
		push_warning("HUD: o WorldEnvironment não tem um Environment configurado.")
		return

	ambiente.environment.adjustment_enabled = true
	ambiente.environment.adjustment_brightness = 0.41
	print("HUD: o ambiente ficou mais escuro!")


func sumir_npcs() -> void:
	if npcs_sumiram:
		return

	npcs_sumiram = true

	for npc in npcs_para_sumir:
		if is_instance_valid(npc):
			npc.call("sumir")

	print("HUD: todos os NPCs desapareceram às 22:00!")


func chamar_dialogo_horario(horario: int, nomeDoNegocio: Dictionary) -> void:
	if dialogos_horarios_exibidos.has(horario):
		return

	dialogos_horarios_exibidos.append(horario)

	if is_instance_valid(dialogos):
		dialogos.call("dialogDiarioAbri", nomeDoNegocio)


func criar_jumpscare() -> void:
	if jumpscare_criado:
		return

	jumpscare_criado = true

	if jumpscare == null:
		push_warning("HUD: configure a cena Jumpscare no Inspector.")
		return

	if not is_instance_valid(marcador_susto):
		push_warning("HUD: configure o Marker3D em 'marcador_susto'.")
		return

	var cena_susto := jumpscare.instantiate()

	if not cena_susto is Node3D:
		push_warning("HUD: a raiz da cena Jumpscare precisa ser Node3D.")
		cena_susto.queue_free()
		return

	cena_susto.hud = self
	get_tree().current_scene.add_child(cena_susto)
	cena_susto.global_transform = marcador_susto.global_transform

	if cena_susto.has_method("iniciar_susto"):
		cena_susto.call_deferred("iniciar_susto")
	else:
		push_warning("HUD: a cena Jumpscare não tem iniciar_susto().")


func _on_button_pressed() -> void:
	$menu.hide()
	get_tree().paused = false
	imagan.show()
	atividd.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_mort_1_pressed() -> void:
	registrar_resultado_partida(true)
	get_tree().paused = false
	Gobla.morreu = true
	Gobla.atividadeDahora = "PODEPEGARCAIXA"

	if is_instance_valid(ambiente) and is_instance_valid(ambiente.environment):
		ambiente.environment.adjustment_enabled = true
		ambiente.environment.adjustment_brightness = 1.0

	get_tree().change_scene_to_file("res://cenas/main.tscn")


func _on_mort_2_pressed() -> void:
	get_tree().quit()


func registrar_resultado_partida(morreu: bool) -> void:
	if partida_registrada:
		return

	partida_registrada = true

	var caixas_entregues: int = 0
	var sistema = get_tree().get_first_node_in_group("sistema_caixas")

	if sistema != null:
		caixas_entregues = sistema.entregasCorretas

	Gobla.registrar_partida(
		int(tempo_partida_segundos),
		caixas_entregues,
		morreu
	)

	print("RANKING: partida registrada!")
	print("Tempo: ", int(tempo_partida_segundos), " segundos")
	print("Caixas: ", caixas_entregues)
	print("Morreu: ", morreu)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if Gobla.atividadeDahora != "UTIMASHORA":
		return

	jogador_na_area_fuga = true
	fuga_ativada = false

	print("Você entrou na área de fuga. Aperte E!")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	jogador_na_area_fuga = false

	if Gobla.atividadeDahora != "UTIMASHORA":
		return

	if not fuga_ativada:
		print("Você saiu sem ativar a fuga com E!")
		return

	if contagem_finalizada or segundos_restantes <= 0:
		print("Tempo esgotado! Você não conseguiu fugir.")
		fuga_ativada = false
		return

	fuga_ativada = false

	print("SOBREVIVEU! Você fugiu antes do tempo acabar!")

	registrar_resultado_partida(false)
