extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(player_info)
signal player_disconnected(player_info)
signal server_disconnected

const PORT = 7078
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players_loaded = 0

var player_data : PlayerData

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	player_data = PlayerData.new().constructor()
	print(player_data.serialize())


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	player_data.network_id = multiplayer.get_unique_id()
	await SceneManager.switch_scene("world")
	Game.add_player(player_data)
	


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	player_data.network_id = multiplayer.get_unique_id()
	player_connected.emit(1, player_data)
	Game.add_player(player_data)
	
	SceneManager.switch_scene("world")
	

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
#@rpc("call_local", "reliable")
#func load_game(game_scene_path):
	#get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	SceneManager.switch_scene("world")
	#if multiplayer.is_server():
		#players_loaded += 1
		#if players_loaded == players.size():
			#$/root/Game.start_game()
			#players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print(player_data.serialize())
	_register_player.rpc_id(id, player_data.serialize())


@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary):
	var new_player_id = multiplayer.get_remote_sender_id()
	var player_data = PlayerData.deserialize(new_player_info)
	player_data.network_id = new_player_id
	Game.add_player(player_data)
	player_connected.emit(player_data)
	


func _on_player_disconnected(id):
	
	player_disconnected.emit(Game.player_with_id(id))
	Game.remove_id(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	#players[peer_id] = player_info
	#player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	#players.clear()
	server_disconnected.emit()
