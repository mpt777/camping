extends Node

var players : Dictionary[int, PlayerData]
signal SyncPlayers

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)

func _on_player_connected(id):
	print("Connected!", id)
	_register_player.rpc_id(id, Game.players[multiplayer.get_unique_id()].serialize())
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary):
	var new_player_id = multiplayer.get_remote_sender_id()
	Game.players[new_player_id] = PlayerData.deserialize(new_player_info)
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
			
