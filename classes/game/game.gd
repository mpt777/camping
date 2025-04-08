extends Node


const FISH = preload("res://scenes/items/fish/fish_data.gd")
const FISH_TYPE = preload("res://scenes/items/fish/fish/golden_trout.tres")

var players : Dictionary[int, PlayerData]
signal SyncPlayers
var is_headless = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	Signals.AddMessage.connect(add_message)

func _on_player_connected(id):
	var uid = multiplayer.get_unique_id() 
	if uid in Game.players:
		_register_player.rpc_id(id, {"player": Game.players[uid].serialize(), "id": uid})
		
		
@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary):
	self.register_player(PlayerData.deserialize(new_player_info["player"]), new_player_info["id"])
	
func register_player(player_data : PlayerData, id: int) -> void:
	Game.players[id] = player_data
	Game.SyncPlayers.emit()
	#Signals.PlayerAdded.emit(id, player_data)
	
	if multiplayer.is_server():
		var message : String = player_data.name + " has joined"
		Signals.AddMessage.emit(Message.new().constructor(message, [0], id))


@rpc("any_peer", "call_local", "reliable", 1)
func _add_message(message_data: Dictionary):
	var message : Message = Message.deserialize(message_data)
	Signals.AddMessageToBox.emit(message)
	
func add_message(message : Message) -> void:
	var tos : Array[int] = message.to
	if len(message.to) == 1 and message.to[0] == 0:
		tos = Game.players.keys()
	for to in tos:
		self._add_message.rpc_id(to, message.serialize())
	
	
func current_player() -> PlayerData:
	return self.players.get(multiplayer.get_unique_id())
