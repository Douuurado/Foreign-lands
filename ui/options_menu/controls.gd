extends Control

## Caminho do arquivo da cena do jogo (ex: "res://scenes/levels/level_01.tscn").
@export var level_path:String
## Caminho do arquivo da cena do menu de opções (ex: "res://scenes/menus/options.tscn").
@export var level_path1:String

## Carrega a cena principal do jogo quando o botão de jogar é pressionado.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(level_path)

## Carrega a cena do menu de configurações/opções quando o botão correspondente é pressionado.
func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file(level_path1)

## Fecha o aplicativo e encerra a execução do jogo imediatamente.
func _on_exit_button_pressed() -> void:
	get_tree().quit() # Se o jogo for lançado em navegador, o comando não funcionará por limitações de segurança do navegador
