extends Control

## Fecha o aplicativo e encerra a execução do jogo ao pressionar o botão de voltar/sair.
func _on_back_pressed() -> void:
	get_tree().quit()
	
## Retoma o fluxo normal do jogo e oculta a interface do menu de pausa.
func _on_continue_pressed() -> void:
	# Retoma o processamento da física e dos nós do jogo
	get_tree().paused = false
	# Oculta o nó pai que contém a interface visual deste menu
	get_parent().visible = false
