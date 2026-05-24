extends Control

## Caminho do arquivo da cena que será carregada (ex: "res://scenes/menus/main_menu.tscn").
@export var level_path:String

## Altera a cena atual do jogo para o arquivo configurado ao pressionar o botão.
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(level_path)
