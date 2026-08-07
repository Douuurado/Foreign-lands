## Autoload (GDD seção 9.1-9.2) que tem permissão de ESCREVER o estado
## político das ilhas. Todo o resto — NPCs, Totem, gatilhos de evento,
## cenário — só lê e reage, nunca escreve direto. É o mesmo princípio que já
## existe no projeto pro HealthManager: nenhum script escreve
## current_health direto, tudo passa por decrease_health/increase_health.
##
## Pra criar uma ilha nova: salve um IslandDefinition novo (seção 9.3) dentro
## de res://resources/islands/ — WorldState carrega a pasta inteira sozinho,
## não precisa registrar em nenhum outro lugar.
extends Node

## Os cinco estados (seção 8), na ordem de prioridade de checagem —
## mais extremo primeiro, o primeiro que bater vale.
const STATE_REVOLUCAO := &"revolucao"
const STATE_REPRESSAO := &"repressao"
const STATE_REVOLTA := &"revolta"
const STATE_TENSAO := &"tensao"
const STATE_PAZ := &"paz"

const ISLAND_DEFINITIONS_DIR := "res://resources/islands"
const SAVE_DIR := "user://saves"

## Emitido sempre que o favor de uma facção muda, em qualquer ilha. NPCs
## assinam isso pra reagir na hora, mesmo no meio da sessão (seção 9.5) —
## do mesmo jeito que a wave_label da UI já reage a wave_started sem o
## Totem saber que ela existe.
signal favor_changed(island_id: StringName, faction_id: StringName, new_value: int)
## Emitido só quando o estado CALCULADO (seção 8) realmente muda de um pra
## outro — não a cada tick, só na transição.
signal state_changed(island_id: StringName, old_state: StringName, new_state: StringName)
## Emitido quando uma flag de missão/mundo muda (ex: &"execucao_impedida").
signal mission_flag_changed(island_id: StringName, flag_name: StringName, value: Variant)

var _definitions: Dictionary = {}   # island_id -> IslandDefinition
var _data: Dictionary = {}          # island_id -> IslandData

func _ready() -> void:
	_load_all_definitions()
	if _definitions.is_empty():
		# Nenhum .tres criado ainda em resources/islands/ — registra Vaelmoor
		# com os valores padrão do GDD (seção 4.1) pra dar pra testar via
		# print (seção 9.8, passo 1) sem depender do Editor.
		register_island(_make_fallback_vaelmoor_definition())

## Registra uma ilha: guarda a definição e cria (ou carrega um save
## existente — seção 9.7) o IslandData correspondente.
func register_island(definition: IslandDefinition) -> void:
	_definitions[definition.island_id] = definition
	var loaded: IslandData = _load_island_data(definition.island_id)
	_data[definition.island_id] = loaded if loaded else _make_default_data(definition)

## PONTO ÚNICO DE ESCRITA de favor. Recebe deltas no formato da tabela 4.2 do
## GDD, ex: {&"coroa": -12, &"rebeldes": 15}. Nunca altere faction_favor
## direto de fora — sempre passe por aqui.
func apply_reputation(island_id: StringName, deltas: Dictionary) -> void:
	var data: IslandData = get_island_data(island_id)
	if data == null:
		return
	for faction_id in deltas:
		var delta: int = deltas[faction_id]
		var current: int = data.faction_favor.get(faction_id, 0)
		var new_value: int = clampi(current + delta, 0, 100)
		if new_value == current:
			continue
		data.faction_favor[faction_id] = new_value
		favor_changed.emit(island_id, faction_id, new_value)
	_recompute_state(island_id)

## Chame isso a cada novo ciclo do Totem (seção 4.1: latent_pressure sobe +3
## sozinha por ciclo; acima do limiar de fuga de controle, o favor rebelde
## também sobe sozinho — o povo perde a paciência mesmo sem o jogador agir).
func on_totem_cycle(island_id: StringName) -> void:
	var definition: IslandDefinition = _definitions.get(island_id)
	var data: IslandData = get_island_data(island_id)
	if definition == null or data == null:
		return

	data.latent_pressure = clampi(data.latent_pressure + definition.pressure_per_cycle, 0, 100)

	if data.latent_pressure > definition.pressure_runaway_threshold and definition.faction_ids.size() > 1:
		var favor_b_id: StringName = definition.faction_ids[1]
		var current: int = data.faction_favor.get(favor_b_id, 0)
		var new_value: int = clampi(current + definition.runaway_favor_b_gain, 0, 100)
		if new_value != current:
			data.faction_favor[favor_b_id] = new_value
			favor_changed.emit(island_id, favor_b_id, new_value)

	_recompute_state(island_id)

## Define uma flag de missão/mundo (ex: &"execucao_impedida", true).
func set_mission_flag(island_id: StringName, flag_name: StringName, value: Variant) -> void:
	var data: IslandData = get_island_data(island_id)
	if data == null:
		return
	data.mission_flags[flag_name] = value
	mission_flag_changed.emit(island_id, flag_name, value)

func get_mission_flag(island_id: StringName, flag_name: StringName, default_value: Variant = false) -> Variant:
	var data: IslandData = get_island_data(island_id)
	return data.mission_flags.get(flag_name, default_value) if data else default_value

func get_island_data(island_id: StringName) -> IslandData:
	return _data.get(island_id)

func get_definition(island_id: StringName) -> IslandDefinition:
	return _definitions.get(island_id)

func get_state(island_id: StringName) -> StringName:
	var data: IslandData = get_island_data(island_id)
	return data.current_state if data else STATE_PAZ

func get_favor(island_id: StringName, faction_id: StringName) -> int:
	var data: IslandData = get_island_data(island_id)
	return data.faction_favor.get(faction_id, 0) if data else 0

## Neutralidade (seção 4.3) não é uma terceira barra — é uma ZONA DERIVADA:
## o jogador está "neutro/equilibrado" quando as duas facções principais
## estão ambas entre 45 e 65.
func is_neutral_zone(island_id: StringName) -> bool:
	var definition: IslandDefinition = _definitions.get(island_id)
	var data: IslandData = get_island_data(island_id)
	if definition == null or data == null or definition.faction_ids.size() < 2:
		return false
	var favor_a: int = data.faction_favor.get(definition.faction_ids[0], 0)
	var favor_b: int = data.faction_favor.get(definition.faction_ids[1], 0)
	return favor_a >= 45 and favor_a <= 65 and favor_b >= 45 and favor_b <= 65

## Salva o IslandData (seção 9.7) — como é um Resource, isso é literalmente
## a única linha que o save de ilha precisa.
func save_island(island_id: StringName) -> void:
	var data: IslandData = get_island_data(island_id)
	if data == null:
		return
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	ResourceSaver.save(data, "%s/%s.tres" % [SAVE_DIR, island_id])

# ---------------------------------------------------------------------------
# Privado
# ---------------------------------------------------------------------------

func _load_all_definitions() -> void:
	var dir := DirAccess.open(ISLAND_DEFINITIONS_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var definition := load(ISLAND_DEFINITIONS_DIR.path_join(file_name)) as IslandDefinition
			if definition:
				register_island(definition)
		file_name = dir.get_next()
	dir.list_dir_end()

func _make_default_data(definition: IslandDefinition) -> IslandData:
	var data := IslandData.new()
	data.island_id = definition.island_id
	for i in definition.faction_ids.size():
		var favor := 50
		if i < definition.starting_favor.size():
			favor = definition.starting_favor[i]
		data.faction_favor[definition.faction_ids[i]] = favor
	data.current_state = STATE_PAZ
	return data

func _load_island_data(island_id: StringName) -> IslandData:
	var path := "%s/%s.tres" % [SAVE_DIR, island_id]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as IslandData

func _make_fallback_vaelmoor_definition() -> IslandDefinition:
	var definition := IslandDefinition.new()
	definition.island_id = &"vaelmoor"
	definition.display_name = "Vaelmoor"
	definition.faction_ids = [&"coroa", &"rebeldes"]
	definition.starting_favor = [50, 15]
	return definition

## Recalcula o estado (tabela da seção 8) e só emite state_changed se ele
## realmente mudou. O estado nunca é setado à mão em outro lugar — é isso
## que evita o bug clássico de "o estado dessincronizou da reputação",
## porque não existe cópia redundante pra dessincronizar.
func _recompute_state(island_id: StringName) -> void:
	var definition: IslandDefinition = _definitions.get(island_id)
	var data: IslandData = get_island_data(island_id)
	if definition == null or data == null or definition.faction_ids.size() < 2:
		return

	var favor_a: int = data.faction_favor.get(definition.faction_ids[0], 0)  # equivalente a crown_favor
	var favor_b: int = data.faction_favor.get(definition.faction_ids[1], 0)  # equivalente a rebel_favor

	var new_state: StringName
	if (favor_a >= definition.revolution_favor_threshold and favor_b >= definition.revolution_favor_threshold) \
			or data.latent_pressure >= definition.revolution_pressure_threshold:
		new_state = STATE_REVOLUCAO
	elif favor_a >= definition.domination_high_threshold and favor_b < definition.domination_low_threshold:
		new_state = STATE_REPRESSAO
	elif favor_b >= definition.domination_high_threshold and favor_a < definition.domination_low_threshold:
		new_state = STATE_REVOLTA
	elif data.latent_pressure >= definition.tension_pressure_threshold or favor_b >= definition.tension_favor_threshold:
		new_state = STATE_TENSAO
	else:
		new_state = STATE_PAZ

	if new_state != data.current_state:
		var old_state := data.current_state
		data.current_state = new_state
		state_changed.emit(island_id, old_state, new_state)
