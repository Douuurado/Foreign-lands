extends Node

@onready var spawner = $"../Spawner"

var current_wave = 1
var enemies_alive = 0
var base_enemies = 1
var enemies_per_wave = 1


@export var initial_enemies = 1
@export var extra_per_wave = 1
@export var delay_between_waves = 3.0
@export var spawn_delay = 0.4
@export var spawn_enemy = 4
var wave_finished = false
var waiting_next_wave = false

func _ready():
	print(spawner)
	EnemyHealthManager.enemy_died.connect(_on_enemy_died)
	start_wave()


func start_wave():
	var amount = initial_enemies + ((current_wave - 1) * extra_per_wave)
	enemies_alive = amount
	wave_finished = false
	
	print("WAVE ", current_wave)
	print("Inimigos:", amount)

	spawn_wave(amount)


func spawn_wave(amount):
	for i in range(amount):
		spawner.spawn_enemy()
		await get_tree().create_timer(spawn_delay).timeout


func _on_enemy_died(enemy):
	enemies_alive -= 1

	print("Vivos:", enemies_alive)
	print("waiting =", waiting_next_wave)

	if enemies_alive <= 0 and not waiting_next_wave:
		waiting_next_wave = true
		next_wave()


func next_wave():
	print("ENTROU NEXT_WAVE")

	await get_tree().create_timer(delay_between_waves).timeout

	current_wave += 1

	waiting_next_wave = false

	start_wave()
