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
