class_name gun_base extends Node2D

const MIN_DISTANCE = 8

@export var fire_rate = 0.2
@export var bullet_speed = 1000
@export var damage = 10
@export var spread = 0
var last_time_shot = 0.0

var flip_threshold = 135

var bullet_scene = preload("res://scenes/projectiles/bullet_base.tscn")
@onready var muzzle : Marker2D = $Marker2D

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var distance_to_mouse = global_position.distance_to(mouse_pos)
	
	if distance_to_mouse > MIN_DISTANCE:
		look_at(get_global_mouse_position())
		rotation_degrees = wrap(rotation_degrees, 0, 360)
		
		if rotation_degrees > flip_threshold and rotation_degrees < (360-flip_threshold):
			scale.y = -1
			position.x = -6
			flip_threshold = 315
			
		elif (rotation_degrees < (360 - flip_threshold) or rotation_degrees > flip_threshold)						:
			scale.y = 1
			position.x = 6
			flip_threshold = 135	
		
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
	#	$shoot_sound.play()
	
	
