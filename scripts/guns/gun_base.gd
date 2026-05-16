class_name gun_base extends Node2D

const MIN_DISTANCE = 8
@export var fire_rate = 0.2
@export var bullet_speed = 1000
@export var damage = 10
@export var spread = 0
var last_time_shot = 0.0
var flip_threshold = 135
var facing_left := false

var bullet_scene = preload("res://scenes/projectiles/bullet_base.tscn")
@onready var muzzle : Marker2D = $Marker2D

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position

	if direction.length_squared() <= MIN_DISTANCE * MIN_DISTANCE:
		return

	look_at(mouse_pos)

	var angle = wrapf(rotation_degrees, 0.0, 360.0)

	# Anti flicker
	if facing_left:
		if angle < 125.0 or angle > 325.0:
			facing_left = false
	else:
		if angle > 145.0 and angle < 305.0:
			facing_left = true

	scale.y = -1 if facing_left else 1
	position.x = -6 if facing_left else 6

	last_time_shot += delta

	if Input.is_action_pressed("shoot") and last_time_shot >= fire_rate:
		shoot()
	
func shoot():
	last_time_shot = 0.0
	
	var bullet_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_instance)
	
	bullet_instance.global_position = muzzle.global_position
	
	var spread_angle = randf_range(-spread, spread)
	bullet_instance.global_rotation =  global_rotation + deg_to_rad(spread_angle)
	
	if bullet_instance.has_method("setup"):
		bullet_instance.setup(bullet_speed, damage)
	else:
		print("Method 'setup' not identified or inserted")
		
	
	#if has_node("shoot_sound"):
		$shoot_sound.play()
