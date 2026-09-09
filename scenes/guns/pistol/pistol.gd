class_name GunPistol extends Node2D

const MIN_DISTANCE = 8
@export var fire_rate = 0.2
@export var bullet_speed = 1000
@export var damage = 10
@export var spread = 0

var last_time_shot = 0.0
var facing_left := false
var bullet_scene = preload("res://scenes/projectiles/bullet_demo.tscn")

@onready var gun_visual: Node2D = $GunVisual
@onready var muzzle: Marker2D = $GunVisual/Marker2D

## Referências às mãos do personagem, atribuídas pelo personagem ao instanciar a arma.
var hand_right: Marker2D
var hand_left: Marker2D

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position
	if direction.length_squared() <= MIN_DISTANCE * MIN_DISTANCE:
		return

	look_at(mouse_pos)
	var angle = rad_to_deg(direction.angle())

	if facing_left:
		if angle < 80 and angle > -80:
			facing_left = false
	else:
		if angle > 100 or angle < -100:
			facing_left = true

	gun_visual.scale.y = -1 if facing_left else 1

	if hand_right and hand_left:
		global_position = hand_left.global_position if facing_left else hand_right.global_position

	last_time_shot += delta
	if Input.is_action_pressed("shoot") and last_time_shot >= fire_rate:
		shoot()

func try_shoot() -> bool:
	if last_time_shot >= fire_rate:
		shoot()
		return true
	return false

func shoot():
	last_time_shot = 0.0
	var bullet_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	var spread_angle = randf_range(-spread, spread)
	bullet_instance.global_rotation = global_rotation + deg_to_rad(spread_angle)
	if bullet_instance.has_method("setup"):
		bullet_instance.setup(bullet_speed, damage)
	else:
		print("Method 'setup' not identified or inserted")
