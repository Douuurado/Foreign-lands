extends GunDemo

@export var custom_fire_rate = 0.15
@export var custom_bullet_speed = 1000
@export var custom_damage = 1
@export var custom_spread = 5

var custom_bullet_scene = preload("res://scenes/projectiles/thompson_bullet.tscn")

func _ready() -> void:
	fire_rate = custom_fire_rate
	bullet_speed = custom_bullet_speed
	damage = custom_damage
	spread = custom_spread
	bullet_scene = custom_bullet_scene
