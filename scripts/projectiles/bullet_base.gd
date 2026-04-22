class_name bullet_base extends Node2D

var speed = 0
var damage = 0

func setup(bullet_speed: float, bullet_damage: int) -> void:
	speed = bullet_speed
	damage = bullet_damage


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_hurtbox_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage)
