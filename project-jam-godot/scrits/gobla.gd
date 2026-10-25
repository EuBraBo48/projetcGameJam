extends Node



var atividadeDahora: String = "PODEPEGARCAIXA"
var morreu: bool = false
var pontos: int = 0

var itens_comprados: Dictionary = {
	"": true
}
var mao_equipada: String = ""

var animal_selecionado: String = ""
var tempo_extra_animal: int = 0
var ranking_partidas: Array[Dictionary] = []
func registrar_partida(tempo_segundos: int, caixas: int, morreu: bool) -> void:
	ranking_partidas.append({
		"tempo": tempo_segundos,
		"caixas": caixas,
		"morreu": morreu
	})

	ranking_partidas.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return int(a["tempo"]) < int(b["tempo"])
	)
