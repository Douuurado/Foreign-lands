extends Control

@export var level_path:String
@export var level_path1:String

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(level_path)

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file(level_path1)

func _on_exit_button_pressed() -> void:
		get_tree().quit()

	
