extends Node3D
class_name World

const PLAYER = preload("res://scenes/player/player.tscn")
@onready var n_characters := %Characters

func _ready():
	if not multiplayer.is_server():
		return
	#Lobby.player_connected.connect(spawn_player)
	
	for player in Game.players:
		spawn_player(player)
		
func spawn_player(player_data: PlayerData) -> void:
	var player = PLAYER.instantiate().constructor(player_data)
	n_characters.add_child(player, true)
