extends Control
class_name Settings


func _on_main_menu_pressed() -> void:
	if not multiplayer.is_server():
		multiplayer.multiplayer_peer = null
	#get_tree().paused = true
	Signals.emit_signal("ChangeScene", "main_menu")


func _on_quit_pressed() -> void:
	get_tree().quit()
