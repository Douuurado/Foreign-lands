extends Node

## Vida máxima inicial configurável pelo editor.
@export var max_health : int = 3
## Quantidade de vida atual do personagem durante o jogo.
var current_health : int

## Emitido sempre que a vida sofre alteração (dano ou cura).
signal on_health_changed(new_health)
## Emitido quando a vida chega a zero.
signal died

## Inicializa a vida atual com o valor máximo configurado.
func _ready():
	current_health = max_health

## Reduz a quantidade de vida especificada e verifica se o personagem morreu.
func decrease_health(health_amount : int):
	# Evita processar dano repetido depois que o jogador já morreu
	if current_health <= 0:
		return

	current_health -= health_amount
	if current_health < 1:
		current_health = 0
		on_health_changed.emit(current_health)
		die()
	else:
		on_health_changed.emit(current_health)

## Incrementa a vida respeitando o limite máximo definido em max_health.
func increase_health(health_amount : int):
	current_health += health_amount
	if current_health > max_health:
		current_health = max_health
	on_health_changed.emit(current_health)

## Notifica o sistema sobre a morte do jogador.
func die():
	died.emit()
	# IMPORTANTE: não chamamos queue_free() aqui.
	# HealthManager é um autoload (singleton) — existe uma única vez durante
	# todo o jogo. Destruí-lo quebraria a vida do jogador pro resto da sessão.

## Restaura a vida cheia. Chame isso ao reiniciar a partida.
func reset_health():
	current_health = max_health
	on_health_changed.emit(current_health)
