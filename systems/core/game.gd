extends Node2D

## Detecta comandos que não foram consumidos pela interface (UI) para pausar o jogo.
func _unhandled_input(event):
	# Verifica se o jogador apertou a tecla de cancelar (geralmente Esc ou Start)
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		
## Pausa o processamento do jogo e exibe a interface do menu de pausa.
func toggle_pause():
	get_tree().paused = true
	$PauseMenu.visible = true
