extends Node

@onready var spawner = $"../Spawner"

var current_wave = 1
var enemies_alive = 0

@export var initial_enemies = 10
@export var extra_per_wave = 2
@export var delay_between_waves = 3.0
@export var spawn_delay = 0.4
@export var spawn_enemy = 4

func _ready():
	print(spawner)
	EnemyHealthManager.enemy_died.connect(_on_enemy_died)
	start_wave()


func start_wave():
	var amount = initial_enemies + ((current_wave - 1) * extra_per_wave)

	enemies_alive = amount

	print("Wave:", current_wave)
	print("Inimigos:", amount)

	spawn_wave(amount)


func spawn_wave(amount):
	for i in range(amount):
		spawner.spawn_enemy()
		await get_tree().create_timer(spawn_delay).timeout


func _on_enemy_died(enemy):
	enemies_alive -= 1

	if enemies_alive <= 0:
		next_wave()


func next_wave():
	print("Wave completa")

	await get_tree().create_timer(delay_between_waves).timeout

	current_wave += 1
	start_wave()
