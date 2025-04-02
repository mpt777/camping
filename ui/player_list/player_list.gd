extends Control
class_name PlayerList

const PEER_CONTROLS = preload("res://ui/peer_controls/peer_controls.tscn")
@onready var n_container := %Container

func _ready() -> void:
	if not multiplayer.is_server():
		return
	Lobby.player_connected.connect(add_player)
	Lobby.player_disconnected.connect(remove_player)
	
	for player in Game.players:
		add_player(player)

func add_player(player_data: PlayerData) -> void:
	var peer = PEER_CONTROLS.instantiate().constructor(player_data)
	n_container.add_child(peer, true)
	
func remove_player(player_data: PlayerData) -> void:
	for child in n_container.get_children():
		if child.player_data == player_data:
			child.queue_free()
	
func _physics_process(delta: float) -> void:
	print(Game.players.map(func(x): return x.name))
