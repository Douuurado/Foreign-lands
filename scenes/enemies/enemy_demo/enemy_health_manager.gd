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
	# Garante que o inimigo informado ainda existe e está registrado no dicionário
	if enemy in enemies:
		enemies[enemy] -= amount
		
		# Verifica se os pontos de vida do inimigo chegaram ao fim
		if enemies[enemy] <= 0:
			enemy_died.emit()
			enemy.queue_free() # Remove o inimigo do cenário e libera a memória
			enemies.erase(enemy) # Remove o registro do inimigo do dicionário global
		else:
			# Notifica outros sistemas (como barras de vida locais) que a vida deste inimigo mudou
			on_health_changed.emit(enemy, enemies[enemy])
