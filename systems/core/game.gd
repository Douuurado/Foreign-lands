extends Node2D

@onready var pause_menu = $PauseMenu

## Conecta a morte do jogador à tela de game over assim que o jogo começa.
func _ready() -> void:
	HealthManager.died.connect(_on_player_died)

## Detecta comandos que não foram consumidos pela interface (UI) para pausar o jogo.
func _unhandled_input(event):
	# Verifica se o jogador apertou a tecla de cancelar (geralmente Esc ou Start)
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

## Pausa o processamento do jogo e exibe a interface do menu de pausa.
func toggle_pause():
	get_tree().paused = true
	pause_menu.visible = true

## Chamado quando o HealthManager emite "died". Mostra a tela de game over.
func _on_player_died() -> void:
	get_tree().paused = true
	_show_game_over_screen()

## Monta a tela de "Você morreu" direto por código (sem precisar de cena nova no editor).
func _show_game_over_screen() -> void:
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)

	var panel := ColorRect.new()
	panel.color = Color(0, 0, 0, 0.75)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(panel)

	var label := Label.new()
	label.text = "Você morreu"
	label.add_theme_font_size_override("font_size", 32)
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.position = Vector2(-120, 100)
	panel.add_child(label)

	var restart_button := Button.new()
	restart_button.text = "Reiniciar"
	restart_button.position = Vector2(270, 170)
	restart_button.pressed.connect(_on_restart_pressed)
	panel.add_child(restart_button)

## Reseta a vida e recarrega a cena para jogar de novo.
func _on_restart_pressed() -> void:
	get_tree().paused = false
	HealthManager.reset_health()
	get_tree().reload_current_scene()
