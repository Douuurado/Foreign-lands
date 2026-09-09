extends CharacterBody2D

@export var speed : int = 200
@export var max_health : int = 3
@export var damage_amount : int = 1
@export var attack_range : float = 500.0
@onready var weapon = $Pistol

var follow_range = 800
var min_distance = 20
var target_chase = true
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
	else:
		velocity = Vector2.ZERO

func attack() -> void:
	if not can_attack or weapon == null:
		return
	can_attack = false
	weapon.try_shoot()

	await get_tree().create_timer(1.0).timeout
	can_attack = true

	if target and target.has_method("take_damage"):
		target.take_damage(damage_amount)

	await get_tree().create_timer(1.0).timeout
	can_attack = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	print("Detectou: ", body.name)
	target = body
	target_chase = true

## Limpa a referência do alvo e interrompe a perseguição quando ele se afasta.
func _on_detection_area_body_exited(_body: Node2D) -> void:
	print("Perseguindo, dist: ", global_position.distance_to(target.global_position))
	target = null
	target_chase = false

## Encaminha a solicitação de redução de vida para o gerenciador central de inimigos.
func take_damage(amount):
	get_node("/root/EnemyHealthManager").damage_enemy(self, amount)
