extends Node

## Vida máxima inicial configurável pelo editor.
@export var max_health : int = 3
## Quantidade de vida atual do personagem durante o jogo.
var current_health : int

## Emitido sempre que a vida sofre alteração (dano ou cura).
signal on_health_changed(new_health)
## Emitido quando a vida chega a zero, antes do nó ser destruído.
signal died 

## Inicializa a vida atual com o valor máximo configurado.
func _ready():	
	current_health = max_health
	
## Reduz a quantidade de vida especificada e verifica se o personagem morreu.
func decrease_health(health_amount : int):
	current_health -= health_amount
	
	# Verifica se a vida acabou (limiar de morte)
	if current_health < 1:
		die()
		
	print("decrease enemy health: ", health_amount)
	on_health_changed.emit(current_health)
		
## Incrementa a vida respeitando o limite máximo definido em max_health.
func increase_health(health_amount : int):
	current_health += health_amount
	
	# Garante que a vida atual não ultrapasse o teto máximo
	if current_health > max_health:
		current_health = max_health
	
	print("increase enemy health")
	on_health_changed.emit(current_health)
	
## Notifica o sistema sobre a morte e remove o nó da cena.
func die():
	died.emit()
	queue_free()
