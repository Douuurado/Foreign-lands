extends GunDemo

## Tempo de espera (em segundos) entre cada disparo desta submetralhadora (cadência rápida).
@export var custom_fire_rate = 0.15
## Velocidade de deslocamento dos projéteis disparados.
@export var custom_bullet_speed = 1000
## Quantidade de dano que cada projétil causará ao alvo.
@export var custom_damage = 1
## Ângulo máximo de dispersão/imprecisão (em graus) devido ao recuo dos tiros rápidos.
@export var custom_spread = 5

## Armazena o arquivo da cena do projétil específico da metralhadora Thompson.
var custom_bullet_scene = preload("res://scenes/projectiles/thompson_bullet.tscn")

## Faz a arma carregar seus atributos personalizados ao iniciar o nó na cena.
func _ready() -> void:
	# Transfere as configurações locais para as variáveis globais da classe base (GunDemo)
	fire_rate = custom_fire_rate
	bullet_speed = custom_bullet_speed
	damage = custom_damage
	spread = custom_spread
	bullet_scene = custom_bullet_scene
