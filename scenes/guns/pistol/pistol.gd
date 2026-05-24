extends GunDemo

## Tempo de espera (em segundos) entre cada disparo desta arma.
@export var custom_fire_rate = 0.3
## Velocidade de deslocamento dos projéteis disparados por esta arma.
@export var custom_bullet_speed = 1000
## Quantidade de dano que cada projétil desta arma causará.
@export var custom_damage = 1
## Ângulo máximo de dispersão/imprecisão (em graus) dos tiros.
@export var custom_spread = 2

## Armazena o arquivo da cena do projétil específico que esta arma vai disparar.
var custom_bullet_scene = preload("res://scenes/projectiles/bullet_demo.tscn")

## Faz a arma carregar seus atributos personalizados ao iniciar o nó na cena.
func _ready() -> void:
	# Transfere as configurações do editor e a cena do projétil para o script pai (GunDemo)
	fire_rate = custom_fire_rate
	bullet_speed = custom_bullet_speed
	damage = custom_damage
	spread = custom_spread
	bullet_scene = custom_bullet_scene
