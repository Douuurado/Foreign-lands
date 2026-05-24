extends Node2D

## Texto de interface (UI) que exibe o nome da interação atual.
@onready var interact_label: Label = $InteractLabel
## Lista que armazena todas as áreas interativas que estão dentro do alcance.
var current_interations := []
## Controla se o jogador pode interagir (bloqueia novas interações durante um await).
var can_interact := true

## Captura o comando de interação do jogador e executa a ação do objeto mais próximo.
func _input(event: InputEvent) -> void:
	# Verifica se o botão de interagir foi pressionado e se o player não está ocupado
	if event.is_action_pressed("interact") and can_interact:
		if current_interations:
			can_interact = false # Bloqueia novas interações temporariamente
			interact_label.hide()
			
			# Executa a função do objeto mais próximo e aguarda sua conclusão
			await current_interations[0].interact.call()
			
			can_interact = true # Libera o jogador para interagir novamente
		

## Atualiza a interface a cada frame com o objeto interativo válido mais próximo.
func _process(_delta: float) -> void:
	if current_interations and can_interact:
		# Ordena a lista para garantir que o índice [0] seja sempre o mais perto
		current_interations.sort_custom(_sort_by_nearest)
		
		# Se o objeto mais próximo estiver ativo, atualiza e exibe o texto na tela
		if current_interations[0].is_interactable:
			interact_label.text = current_interations[0].interact_name
			interact_label.show()
	else:
		# Esconde o texto caso não haja nada por perto ou o player esteja ocupado
		interact_label.hide()
		

## Algoritmo de comparação para ordenar as áreas com base na distância até o jogador.
func _sort_by_nearest(area1, area2):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	
	# Retorna verdadeiro se a primeira área estiver mais perto do que a segunda
	return area1_dist < area2_dist

## Adiciona uma nova área interativa à lista quando o jogador chega perto.
func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interations.push_back(area)


## Remove a área interativa da lista quando o jogador se afasta dela.
func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interations.erase(area)
