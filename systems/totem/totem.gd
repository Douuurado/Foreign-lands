extends StaticBody2D

## Referência à área de detecção que gerencia a interação.
@onready var interactable: Area2D = $Interactable
## Referência ao sprite visual do objeto no cenário.
@onready var sprite_2d: Sprite2D = $Sprite2D
## Pontos ao redor do totem onde os inimigos vão nascer.
@onready var spawn_points: Array[Marker2D] = [$SpawnPoint1, $SpawnPoint2, $SpawnPoint3, $SpawnPoint4]

## Cena do inimigo instanciada a cada spawn. Arraste enemy_demo.tscn aqui no Inspector.
@export var enemy_scene: PackedScene
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
	if enemy_scene == null or spawn_points.is_empty():
		return
	var point: Marker2D = spawn_points[randi() % spawn_points.size()]
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = point.global_position

## Chamado toda vez que QUALQUER inimigo morre (sinal do EnemyHealthManager).
func _on_enemy_died(_enemy) -> void:
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
