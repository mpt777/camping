extends Node

var players : Array[PlayerData]

func add_player(player_data : PlayerData):
	self.players.append(player_data)
	
func player_with_id(id: int) -> PlayerData:
	for player in self.players:
		if player.network_id == id:
			return player
	return null
			
func remove_id(id: int):
	var player = self.player_with_id(id)
	if player:
		Utils.remove_item(self.players, player)
			
