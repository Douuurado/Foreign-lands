extends CharacterBody2D

@export var speed : int = 200
@export var max_health : int = 3
@export var damage_amount : int = 1

var target_chase = false
var target = null

func _ready():
	get_node("/root/EnemyHealthManager").register_enemy(self, max_health)

func _physics_process(delta: float) -> void:
	if target_chase:
		var direction = (target.position - position).normalized()
		position += direction * speed * delta
		
		

func _on_detection_area_body_entered(body: Node2D) -> void:
		target = body
		target_chase = true


func _on_detection_area_body_exited(_body: Node2D) -> void:
	target = null
	target_chase = false

func take_damage(amount):
	get_node("/root/EnemyHealthManager").damage_enemy(self, amount)
