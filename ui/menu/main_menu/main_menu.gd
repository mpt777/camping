extends Control
class_name MainMenu



func _on_host_pressed() -> void:
	await GlobalUI.transition_in()
	self.set_player_data()
	Signals.emit_signal("HostMultiplayer")


func _on_connect_pressed() -> void:
	await GlobalUI.transition_in()
	self.set_player_data()
	Signals.emit_signal("ConnectMultiplayer", %Remote.text)
	
func _on_join_server_pressed() -> void:
	await GlobalUI.transition_in()
	self.set_player_data()
	Signals.emit_signal("ConnectMultiplayer", Multiplayer.HOST)
	
func set_player_data():
	Game.player_data = PlayerData.new().constructor(%Name.text)
