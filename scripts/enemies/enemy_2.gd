extends CharacterBody2D

@export var speed : int = 200
@export var max_health : int = 3
@export var damage_amount : int = 1
@export var attack_range : float = 30.0

var follow_range = 300
var min_distance = 20
var target_chase = false
var target = null
var can_attack = true

func _ready():
	get_node("/root/EnemyHealthManager").register_enemy(self, max_health)

func _physics_process(delta: float) -> void:
	if target_chase and target != null:
		var dist = global_position.distance_to(target.global_position)

		if dist <= attack_range:
			velocity = Vector2.ZERO
			if can_attack:
				attack()
		elif dist < follow_range and dist > min_distance:
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO

		move_and_slide()

func attack() -> void:
	if not can_attack:
		return
	can_attack = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	target = body
	target_chase = true

func _on_detection_area_body_exited(_body: Node2D) -> void:
	target = null
	target_chase = false

func take_damage(amount):
	get_node("/root/EnemyHealthManager").damage_enemy(self, amount)
