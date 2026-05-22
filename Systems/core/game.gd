extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		
func toggle_pause():
	get_tree().paused = true
	$PauseMenu.visible = true
	
	
