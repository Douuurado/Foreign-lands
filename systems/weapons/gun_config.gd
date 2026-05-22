extends GunDemo

@export var custom_fire_rate = 0.3
@export var custom_bullet_speed = 1500
@export var custom_damage = 3
@export var custom_spread = 15

func _ready() -> void:
	fire_rate = custom_fire_rate
	bullet_speed = custom_bullet_speed
	damage = custom_damage
	spread = custom_spread
