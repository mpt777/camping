extends Node

const PORT = 8120

func _ready():
	# Start paused
	get_tree().paused = true
	# You can save bandwith by disabling server relay and peer notifications.
	#multiplayer.server_relay = false ## fuck this

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		Game.is_headless = true
		print("Automatically starting dedicated server")
		_on_host_pressed.call_deferred()


func _on_host_pressed():
	# Start as server
	var peer := ENetMultiplayerPeer.new()
	#
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
		
	start_game(peer)


func _on_connect_pressed():
	# Start as client
	var txt : String = $UI/Net/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	
	start_game(peer)

func start_game(peer: ENetMultiplayerPeer) -> void:
	# Hide the UI and unpause to start the game.
	
	GlobalUI.n_vignette.visible = true
	multiplayer.multiplayer_peer = peer
	$UI.hide()
	
	get_tree().paused = false
	
	if !Game.is_headless:
		
		var player_data : PlayerData = PlayerData.new().constructor(%Name.text)
		var player_data_dict : Dictionary = Serializer.read_json(PlayerData.save_path(%Name.text))
		if player_data_dict:
			player_data = PlayerData.deserialize(player_data_dict)
			
		Game.register_player(player_data, multiplayer.get_unique_id())
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/world/world.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

# The server can restart the level by pressing HOME.
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level.call_deferred(load("res://scenes/world/world.tscn"))
