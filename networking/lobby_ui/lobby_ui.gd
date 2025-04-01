extends Control
class_name LobbyUI

func _on_host_pressed() -> void:
	Lobby.create_game()


func _on_join_pressed() -> void:
	Lobby.join_game()
