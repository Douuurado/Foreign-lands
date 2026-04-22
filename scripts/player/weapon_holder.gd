extends Node2D

@onready var player_sprite = get_parent().get_node("Body")

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
		player_sprite.flip_h = true
	else:
		scale.y = 1
		player_sprite.flip_h = false
