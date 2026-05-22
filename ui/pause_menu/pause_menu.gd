extends Control

func _on_back_pressed() -> void:
	get_tree().quit()
	
func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_parent().visible = false
