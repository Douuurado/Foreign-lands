extends GunDemo

## Tempo de espera (em segundos) entre cada disparo desta arma.
@export var custom_fire_rate = 0.3
## Velocidade de deslocamento dos projéteis disparados por esta arma.
@export var custom_bullet_speed = 1500
## Quantidade de dano que cada projétil desta arma causará.
@export var custom_damage = 3
## Ângulo máximo de dispersão/imprecisão (em graus) dos tiros.
@export var custom_spread = 15

## Transfere as configurações personalizadas do editor para as variáveis do script pai.
func _ready() -> void:
	fire_rate = custom_fire_rate
	bullet_speed = custom_bullet_speed
	damage = custom_damage
	spread = custom_spread
