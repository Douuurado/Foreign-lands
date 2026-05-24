extends Node2D

## Referência ao sprite do corpo do personagem (nó pai).
@onready var player_sprite = get_parent().get_node("Body")

@warning_ignore("unused_parameter")
## Faz o objeto rotacionar em direção ao mouse e inverte o sprite horizontalmente.
func _physics_process(delta: float) -> void:
	# Rotaciona instantaneamente o nó atual para apontar para o cursor
	look_at(get_global_mouse_position())
	
	# Mantém o ângulo sempre entre 0 e 360 graus para evitar números negativos gigantes
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	# Verifica se o objeto está apontando para a esquerda (zona entre 90° e 270°)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1           # Inverte o eixo Y para a arma/objeto não ficar de cabeça para baixo
		player_sprite.flip_h = true  # Inverte o sprite do personagem para a esquerda
	else:
		scale.y = 1            # Mantém a escala normal (olhando para a direita)
		player_sprite.flip_h = false # Mantém o sprite original para a direita
