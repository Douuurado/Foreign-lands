extends Node

@export var max_health : int = 3
var current_health : int

signal on_health_changed(new_health)
signal died 

func _ready():	
	current_health = max_health
	
func decrease_health(health_amount : int):
	current_health -= health_amount
	
	if current_health < 1:
		die()
		
	print("decrease enemy health: ", health_amount)
	on_health_changed.emit(current_health)
		
func increase_health(health_amount : int):
	current_health += health_amount
	
	if current_health > max_health:
		current_health = max_health
	
	print("increase enemy health")
	on_health_changed.emit(current_health)
	
func die():
	died.emit()
	queue_free()
