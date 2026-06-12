extends Node2D

#mostra o limite minimo do mapa
@export var map_min := Vector2(-317, -355)
#mostra o limite maximo do mapa
@export var map_max := Vector2(315, 355)
#cena do inimigo
@export var enemy_scene: PackedScene
#onde os inimigos vao nascer
@export var spawn_points: Array[Marker2D]
#margem de spawn
@export var spawn_margin := 200
@onready var player

func spawn_enemy():
	#o player
	player = get_tree().get_first_node_in_group("player")
	#variavel enemy
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	# a posição do inimigo
	enemy.global_position = calculate_spawn_position() 
	#onde o inimigo vai atacar, o alvo
	enemy.target = player
	
func calculate_spawn_position() -> Vector2:
	# onde vai nascer
	var spawn_pos: Vector2

	while true:
		#range de spawn minimo que o inimigo pode nascer
		var x = randf_range(map_min.x, map_max.x)
		# range de spawn maximo que o inimigo pode nascer
		var y = randf_range(map_min.y, map_max.y)
		
		#posição de spawn
		spawn_pos = Vector2(x, y)

		# impede spawn perto do player
		if spawn_pos.distance_to(player.global_position) > 150:
			return spawn_pos
	
	return spawn_pos
