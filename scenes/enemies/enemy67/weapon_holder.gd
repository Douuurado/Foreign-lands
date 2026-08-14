@onready var weapon_holder = $WeaponHolder
var weapon = null

func _ready():
	get_node("/root/EnemyHealthManager").register_enemy(self, max_health)
	# se a arma já for filha do WeaponHolder na cena:
	if weapon_holder.get_child_count() > 0:
		weapon = weapon_holder.get_child(0)

func attack() -> void:
	if not can_attack or weapon == null:
		return
	can_attack = false

	weapon_holder.look_at(target.global_position)  # mira na direção do alvo
	weapon.fire()  # nome do método precisa bater com o que existe em gun_base

	await get_tree().create_timer(1.0).timeout
	can_attack = true
