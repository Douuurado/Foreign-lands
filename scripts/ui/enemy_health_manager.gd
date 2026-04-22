extends Node

var enemies = {}

signal on_health_changed(enemy, new_health)
signal enemy_died(enemy)

func register_enemy(enemy, max_health):	
	enemies[enemy] = max_health
	
func damage_enemy(enemy, amount):
	if enemy in enemies:
		enemies[enemy] -= amount
		if enemies[enemy] <= 0:
			enemy_died.emit()
			enemy.queue_free()
			enemies.erase(enemy)
		else:
			on_health_changed.emit(enemy, enemies[enemy])
