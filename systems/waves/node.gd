extends Node

@onready var spawner = $"../Spawner"

# wave atual
var current_wave = 1
# inimigos vivos
var enemies_alive = 0
# inimigos da primeira wave
var base_enemies = 1
# inimigos que sera adicionado por wave
var enemies_per_wave = 1

#inimigos iniciais
@export var initial_enemies = 1
#quanto inimigos sera adicionado por wave
@export var extra_per_wave = 1
#quantos tempo vai começar a proxima wave
@export var delay_between_waves = 3.0
#tempo que demora pra aparecer cada inimigo
@export var spawn_delay = 0.4
#spawm do inimigo
@export var spawn_enemy = 4

# ve se a wave acabou ou não
var wave_finished = false
# espera a proxima wave para começar 
var waiting_next_wave = false

func _ready():
	print(spawner)
	#vida do inimigo
	EnemyHealthManager.enemy_died.connect(_on_enemy_died)
	start_wave()


func start_wave():
	#quantos inimigos iram aparecer dependendo da wave
	var amount = initial_enemies + ((current_wave - 1) * extra_per_wave)
	#o tanto de inimigos vivos
	enemies_alive = amount
	#pergunta se a wave acabou
	wave_finished = false
	
	#mostra wave atual
	print("WAVE ", current_wave)
	#mostra inimigos atuais
	print("Inimigos:", amount)

	spawn_wave(amount)


func spawn_wave(amount):
	#range de spawn dos inimigos(para n spawnar fora do mapa)
	for i in range(amount):
		#vai spawnar o inimigo
		spawner.spawn_enemy()
		# vai criar uma contagem regressiva para o proximo inimigo spawnar
		await get_tree().create_timer(spawn_delay).timeout


func _on_enemy_died(enemy):
	#quantos inimigo tem vivo
	enemies_alive -= 1

	# mostra quantos inimigos tem vivos
	print("Vivos:", enemies_alive)
	print("waiting =", waiting_next_wave)
	
	#se o numeros de inimigos for menor ou igual a 0 vai começar a proxima wave
	if enemies_alive <= 0 and not waiting_next_wave:
		waiting_next_wave = true
		next_wave()


func next_wave():
	print("ENTROU NEXT_WAVE")

	#cria um timer entre waves
	await get_tree().create_timer(delay_between_waves).timeout
	
	# vai acrescentar +1 no numero de waves
	current_wave += 1
	
	#vai mostrar que não esta mais esperando a wave e pode começar a proxima
	waiting_next_wave = false

	start_wave()
