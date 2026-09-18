extends CharacterBody2D

## A qual ilha este inimigo pertence.
@export var island_id: StringName = &"vaelmoor"

@export var speed : int = 200
@export var max_health : int = 3
## Dano causado ao jogador por hit, em CORAÇÕES (o personagem tem 3 no total).
@export var damage_amount : int = 1
@export var ignore_state_mods : bool = false

## Multiplicadores por estado. PAZ = normal (1.0 em tudo, valores do
## Inspector sem alteração). Os estados mais tensos sobem a partir daí.
const STATE_MODS := {
	&"paz":       {"health": 1.0, "speed": 1.0,  "damage": 1.0},
	&"tensao":    {"health": 2.0, "speed": 1.1,  "damage": 1.0},
	&"repressao": {"health": 5.5, "speed": 1.2,  "damage": 2.0},
	&"revolta":   {"health": 2.3, "speed": 1.25, "damage": 2.0},
	&"revolucao": {"health": 2.6, "speed": 1.3,  "damage": 2.0},
} 
const DEFAULT_MODS := {"health": 1.0, "speed": 1.0, "damage": 1.0}  # fallback = paz

var target = null
var target_chase = false

var _base_speed : int
var _base_max_health : int
var _base_damage : int

func _ready():
	_base_speed = speed
	_base_max_health = max_health
	_base_damage = damage_amount

	WorldState.state_changed.connect(_on_world_state_changed)
	_apply_state_mods(WorldState.get_state(island_id))

	get_node("/root/EnemyHealthManager").register_enemy(self, max_health)

func _apply_state_mods(state: StringName) -> void:
	if ignore_state_mods:
		return
	var mods = STATE_MODS.get(state, DEFAULT_MODS)
	max_health = maxi(1, roundi(_base_max_health * mods["health"]))
	speed = roundi(_base_speed * mods["speed"])
	damage_amount = maxi(1, roundi(_base_damage * mods["damage"]))

func _on_world_state_changed(changed_island_id: StringName, _old_state: StringName, new_state: StringName) -> void:
	if changed_island_id != island_id:
		return
	var old_max := max_health
	_apply_state_mods(new_state)
	if old_max != max_health:
		get_node("/root/EnemyHealthManager").rescale_enemy_health(self, old_max, max_health)

func _physics_process(_delta: float) -> void:
	if target_chase and target:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_detection_area_body_entered(body: Node2D) -> void:
	target = body
	target_chase = true

func _on_detection_area_body_exited(_body: Node2D) -> void:
	target = null
	target_chase = false

func take_damage(amount):
	get_node("/root/EnemyHealthManager").damage_enemy(self, amount)

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	pass
