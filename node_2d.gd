extends Node2D

@export var map_min := Vector2(-385, -385)
@export var map_max := Vector2(385, 385)
@export var enemy_scene: PackedScene
@export var spawn_points: Array[Marker2D]
@export var spawn_margin := 200
@onready var player

func spawn_enemy():
	player = get_tree().get_first_node_in_group("player")
	print("player =", player)
	print(get_tree().get_nodes_in_group("player"))
	print("SPAWNANDO")
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = calculate_spawn_position() 
	enemy.target = player
	
func calculate_spawn_position() -> Vector2:
	var spawn_pos: Vector2

	while true:
		var x = randf_range(map_min.x, map_max.x)
		var y = randf_range(map_min.y, map_max.y)

		spawn_pos = Vector2(x, y)

		# impede spawn perto do player
		if spawn_pos.distance_to(player.global_position) > 150:
			return spawn_pos
	
	return spawn_pos
