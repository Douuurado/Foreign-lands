extends Area2D

## Nome ou ação que aparecerá na tela para o jogador (ex: "Abrir Baú", "Conversar").
@export var interact_name: String = ""
## Controla se o objeto pode ser interagido pelo jogador no momento.
@export var is_interactable: bool = true

## Função anônima (Callable) executada quando a interação acontece.
## Deve ser substituída no script que gerencia o objeto interativo.
var interact: Callable = func():
	pass
