extends Node

const VIGNETTE = preload("res://ui/vignette/vignette.tscn")

var players : Dictionary[int, PlayerData]
signal SyncPlayers

var player_data : PlayerData

func _ready():
	Signals.AddMessage.connect(add_message)
	
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
	
	
	
######
func add_vignette():
	VIGNETTE.instantiate().full_constructor(Vector2(0,0))
