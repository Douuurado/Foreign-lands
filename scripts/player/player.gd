class_name player extends CharacterBody2D

const SPEED = 300.0
var invulnerable = false
var invulnerability_time = 0.5

@onready var player_sprite = get_node("Body")


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
			
	if direction != Vector2.ZERO:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	update_animation(direction_to_mouse, velocity.length() > 1.0)
	move_and_slide()

func update_animation(direction_to_mouse: Vector2, is_moving: bool) -> void:
	var anim = ""
	var moving_suffix = "_walk" if is_moving else "_idle"
	if abs(direction_to_mouse.x) > 0.5 and direction_to_mouse.y < -0.5:
		anim = "back_side"
		player_sprite.flip_h = direction_to_mouse.x < 0

	elif abs(direction_to_mouse.x) > abs(direction_to_mouse.y):
		anim = "side"
		player_sprite.flip_h = direction_to_mouse.x < 0

	else:
		anim = "front" if direction_to_mouse.y > 0 else "back"

	var final_anim = anim + moving_suffix

	if $AnimationPlayer.current_animation != final_anim:
		$AnimationPlayer.play(final_anim)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not invulnerable:
		invulnerable = true
		$AnimationPlayer.play("hit_flash")
		HealthManager.decrease_health(body.damage_amount)
		await get_tree().create_timer(invulnerability_time).timeout
		invulnerable = false
