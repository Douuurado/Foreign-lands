extends StaticBody2D

## Referência à área de detecção que gerencia a interação.
@onready var interactable: Area2D = $Interactable
## Referência ao sprite visual do objeto no cenário.
@onready var sprite_2d: Sprite2D = $Sprite2D
## Pontos ao redor do totem onde os inimigos vão nascer.
@onready var spawn_points: Array[Marker2D] = [$SpawnPoint1, $SpawnPoint2, $SpawnPoint3, $SpawnPoint4]

## Cena do inimigo instanciada a cada spawn. Arraste enemy_demo.tscn aqui no Inspector.
## Usado como fallback quando não há island_id/encounter_table configurados,
## ou quando o estado atual não tem nenhuma variante cadastrada (seção 9.4).
@export var enemy_scene: PackedScene
## Qual ilha este Totem pertence. Deixe em &"" pra manter o comportamento
## antigo (sempre enemy_scene, sem sistema político) — GDD seção 9.4.
@export var island_id: StringName = &""
## Tabela de inimigos por estado desta ilha (seção 9.3). Opcional: sem ela,
## o Totem cai de volta pro enemy_scene fixo mesmo com island_id preenchido.
@export var encounter_table: EncounterTable
## Quantos inimigos a primeira wave tem.
@export var base_enemies_per_wave: int = 3
## Quantos inimigos a mais cada wave seguinte ganha.
@export var enemies_added_per_wave: int = 2
## Intervalo entre cada inimigo nascendo dentro da mesma wave.
@export var time_between_spawns: float = 0.5
## Pausa entre uma wave terminar e a próxima começar.
@export var time_between_waves: float = 3.0

## Emitido sempre que uma nova wave começa — a UI escuta isso pra atualizar o texto.
signal wave_started(wave_number: int)

var current_wave: int = 0
var enemies_alive: int = 0
var is_spawning: bool = false
var waves_active: bool = false
var waiting_next_wave: bool = false
## Guarda só os inimigos que ESTA wave spawnou. Sem isso, matar os inimigos que já
## vêm colocados no mapa (Enemy1/Enemy2 em game.tscn) também descontava de
## enemies_alive, porque o sinal enemy_died é global e avisa sobre qualquer morte.
var wave_enemies: Array = []

## Configura o link entre este objeto e o sistema de interações ao iniciar.
func _ready() -> void:
	interactable.interact = _on_interact
	EnemyHealthManager.enemy_died.connect(_on_enemy_died)

## Executa a lógica do totem quando o jogador interage com ele: liga as ondas.
func _on_interact() -> void:
	if waves_active:
		return
	interactable.is_interactable = false
	waves_active = true
	print("Totem ativado — as ondas começam")
	_start_next_wave()

func _start_next_wave() -> void:
	current_wave += 1
	wave_started.emit(current_wave)
	# Seção 4.1/9.6: um "ciclo do Totem" = uma nova wave começando. É a
	# unidade de tempo mais barata pra pressão latente subir sozinha e pra
	# eventos ligados à passagem de tempo se ancorarem, sem precisar de um
	# relógio novo.
	if island_id != &"":
		WorldState.on_totem_cycle(island_id)
	print("Wave ", current_wave)
	var count := base_enemies_per_wave + (current_wave - 1) * enemies_added_per_wave
	_spawn_wave(count)

func _spawn_wave(count: int) -> void:
	is_spawning = true
	for i in range(count):
		_spawn_enemy()
		enemies_alive += 1
		await get_tree().create_timer(time_between_spawns).timeout
	is_spawning = false
	_check_wave_cleared()

func _spawn_enemy() -> void:
	var scene: PackedScene = _pick_enemy_scene()
	if scene == null or spawn_points.is_empty():
		return
	var point: Marker2D = spawn_points[randi() % spawn_points.size()]
	var enemy = scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = point.global_position
	wave_enemies.append(enemy)

## Seção 9.4: pergunta ao WorldState o estado atual da ilha, usa esse estado
## como chave na EncounterTable e escolhe dali. Se não houver island_id ou
## encounter_table configurados, ou se o estado atual não tiver nenhuma
## variante cadastrada ainda, cai pro enemy_scene fixo — comportamento
## antigo 100% preservado.
func _pick_enemy_scene() -> PackedScene:
	if island_id != &"" and encounter_table != null:
		var state: StringName = WorldState.get_state(island_id)
		var options: Array[PackedScene] = encounter_table.get_scenes_for(state)
		if not options.is_empty():
			return options[randi() % options.size()]
	return enemy_scene

## Chamado toda vez que QUALQUER inimigo morre (sinal do EnemyHealthManager).
## Só conta pra wave atual se o inimigo foi spawnado por este totem.
func _on_enemy_died(enemy) -> void:
	if not wave_enemies.has(enemy):
		return
	wave_enemies.erase(enemy)
	enemies_alive -= 1
	_check_wave_cleared()

## Só avança pra próxima wave quando não há spawn pendente nem inimigo vivo.
## Também é o momento da "recompensa simples": cura o jogador por sobreviver.
func _check_wave_cleared() -> void:
	if waiting_next_wave or is_spawning or enemies_alive > 0 or not waves_active:
		return
	waiting_next_wave = true
	HealthManager.reset_health()  # recompensa: cura completa por limpar a wave
	await get_tree().create_timer(time_between_waves).timeout
	waiting_next_wave = false
	_start_next_wave()
