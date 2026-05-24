extends StaticBody2D

## Referência à área de detecção que gerencia a interação.
@onready var interactable: Area2D = $Interactable
## Referência ao sprite visual do objeto no cenário.
@onready var sprite_2d: Sprite2D = $Sprite2D

## Configura o link entre este objeto e o sistema de interações ao iniciar.
func _ready() -> void:
	# Atribui a função local à variável do tipo Callable da Area2D
	interactable.interact = _on_interact
	
## Executa a lógica específica do totem quando o jogador interage com ele.
func _on_interact():
	# Desativa futuras interações com este objeto (interação única)
	interactable.is_interactable = false
	print("The player interacted the totem")
