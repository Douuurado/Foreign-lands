extends Node

## Dicionário que armazena as referências dos inimigos vivos como chaves e suas respectivas vidas atuais como valores.
var enemies = {}

## Emitido quando um inimigo específico sofre alteração em seus pontos de vida.
signal on_health_changed(enemy, new_health)
## Emitido quando um inimigo morre (vida chega a zero ou menos).
signal enemy_died(enemy)

## Registra um novo inimigo no sistema, associando a instância dele à sua vida máxima inicial.
func register_enemy(enemy, max_health):
	enemies[enemy] = max_health

## Aplica uma quantidade de dano a um inimigo registrado e gerencia sua destruição caso a vida acabe.
func damage_enemy(enemy, amount):
	if enemy in enemies:
		enemies[enemy] -= amount

		if enemies[enemy] <= 0:
			enemy_died.emit(enemy)  # antes emitia sem o inimigo — o Totem precisa saber quem morreu
			enemy.queue_free()
			enemies.erase(enemy)
		else:
			on_health_changed.emit(enemy, enemies[enemy])
			## Recalibra a vida de um inimigo já vivo quando o estado da ilha muda,
## mantendo a % de vida atual (não cura nem mata de repente).
## old_max/new_max vêm do próprio inimigo, que é quem sabe seu max_health.
func rescale_enemy_health(enemy, old_max_health: int, new_max_health: int) -> void:
	if not enemies.has(enemy):
		return
	var current = enemies[enemy]
	var ratio = float(current) / float(maxi(old_max_health, 1))
	var new_health = maxi(1, roundi(new_max_health * ratio))
	enemies[enemy] = new_health
	on_health_changed.emit(enemy, new_health)
