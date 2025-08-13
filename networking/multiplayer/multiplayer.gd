extends Node

const HOST = "165.232.138.152"
const PORT = 8120
var is_headless = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	Signals.connect("HostMultiplayer", host_multiplayer)
	Signals.connect("ConnectMultiplayer", connect_multiplayer)
	
	if DisplayServer.get_name() == "headless":
		Multiplayer.is_headless = true
		print("Automatically starting dedicated server")
		host_multiplayer.call_deferred()
	
	#var player_data : PlayerData = PlayerData.new().constructor(%Name.text)
func host_multiplayer():
	# Start as server
	var peer := ENetMultiplayerPeer.new()
	#
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	
	Signals.emit_signal("StartGame", peer)
	#start_game(peer)


func connect_multiplayer(origin : String):
	if origin == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(origin, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	Signals.emit_signal("StartGame", peer)
	#start_game(peer)
	
	
# ======================================
# Player Management
func _on_player_connected(id):
	var uid = multiplayer.get_unique_id() 
	Signals.emit_signal("AddPlayer", id)
	if uid in Game.players:
		_register_player.rpc_id(id, {"player": Game.players[uid].serialize(), "id": uid})
		
func _on_player_disconnected(id):
	Signals.emit_signal("RemovePlayer", id)
	
	
	if not id in Game.players:
		return
	var player_data := Game.players[id]
	Game.players.erase(id)
		
	if multiplayer.is_server():
		var message : String = player_data.name + " has left"
		Signals.AddMessage.emit(Message.new().constructor(message, [0], id))
		
		
@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary):
	self.register_player(PlayerData.deserialize(new_player_info["player"]), new_player_info["id"])
	
func register_player(player_data : PlayerData, id: int) -> void:
	Game.players[id] = player_data
	Game.SyncPlayers.emit()
	
	if multiplayer.is_server():
		var message : String = player_data.name + " has joined"
		Signals.AddMessage.emit(Message.new().constructor(message, [0], id))
