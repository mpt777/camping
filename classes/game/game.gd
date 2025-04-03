extends Node

var players : Dictionary[int, PlayerData]
signal SyncPlayers
var is_headless = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)

# player connects to server, sends information
func _on_player_connected(id):
	#print("New Player ", multiplayer.get_unique_id(), " | ", id)
	#if Game.is_headless:
		#for player_id in Game.players.keys():
			#_register_player.rpc_id(id, {"player": Game.players[player_id].serialize(), "id": player_id})
	#else:
	_register_player.rpc_id(id, {"player": Game.players[multiplayer.get_unique_id()].serialize(), "id": multiplayer.get_unique_id()})
		
	

@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary):
	#var new_player_id = multiplayer.get_remote_sender_id()
	Game.players[new_player_info["id"]] = PlayerData.deserialize(new_player_info["player"])
	Game.SyncPlayers.emit()
	print(Game.players)
	
	
#func add_player(player_data : PlayerData):
	#self.players.append(player_data)
	#
#func player_with_id(id: int) -> PlayerData:
	#for player in self.players:
		#if player.network_id == id:
			#return player
	#return null
			#
#func remove_id(id: int):
	#var player = self.player_with_id(id)
	#if player:
		#Utils.remove_item(self.players, player)
			
