extends Node3D
class_name World

const PLAYER = preload("res://scenes/player/player.tscn")
const PLAYER_GROUPER = preload("res://scenes/player/player_grouper/player_grouper.tscn")
#const PLAYER_GLOBAL = preload("res://scenes/player/player_global/player_global.tscn")

@onready var n_player_spawn = $Players/PlayerSpawn

@onready var n_players = $Players/Players


func _ready():
	# We only need to spawn players on the server.
	#Signals.PlayerLoaded.connect(_add_player_via_rpc)
	
	if not multiplayer.is_server():
		return
	
	Signals.connect("AddPlayer", add_player)
	Signals.connect("RemovePlayer", del_player)
	#multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	#if not OS.has_feature("dedicated_server"):
	if !Multiplayer.is_headless:
		add_player(1)

func _exit_tree():
	if not multiplayer.has_multiplayer_peer():
		return
	if not multiplayer.is_server():
		return
	Signals.disconnect("AddPlayer", add_player)
	Signals.disconnect("RemovePlayer", del_player)
	#multiplayer.peer_connected.disconnect(add_player)
	#multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	print("add ", id)
	var player_grouper = PLAYER_GROUPER.instantiate()
	if id in Game.players:
		player_grouper.constructor(Game.players[id])
	
	player_grouper.name = str(id)
	player_grouper.set_multiplayer_authority(id)
		
	n_players.add_child(player_grouper, true)

func del_player(id: int):
	#if id in Game.players:
		#Game.players.erase(id)
		
	if n_players.has_node(str(id)):
		n_players.get_node(str(id)).queue_free()
		
