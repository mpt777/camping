extends Node
class_name GameManager
# The class that sticky around always. 
# It handles most high level non game specific things, like player and scene management 
# Entry Point into the Game

@onready var level = $Level

const scene_lookup = {
	"island": "res://scenes/world/world.tscn",
	"main_menu": "res://ui/menu/main_menu/main_menu.tscn"
}


#@onready var main_menu : MainMenu = $Level/MainMenu

func _ready():
	# Start paused
	#get_tree().paused = true
	Signals.connect("StartGame", start_game)
	Signals.connect("ChangeScene", change_scene)
	# You can save bandwith by disabling server relay and peer notifications.
	#multiplayer.server_relay = false ## fuck this
	
	# Automatically start the server in headless mode.


func start_game(peer: ENetMultiplayerPeer) -> void:
	# Hide the UI and unpause to start the game.
	
	GlobalUI.n_vignette.visible = true
	multiplayer.multiplayer_peer = peer
	#if self.main_menu:
	#self.main_menu.queue_free()
	
	self.clear_scene()
	
	if !Multiplayer.is_headless:
		
		var player_data : PlayerData = Game.player_data
		var player_data_dict : Dictionary = Serializer.read_json(PlayerData.save_path(player_data.name))
		if player_data_dict:
			player_data = PlayerData.deserialize(player_data_dict)
			
		Multiplayer.register_player(player_data, multiplayer.get_unique_id())
		GlobalUI.transition_in()
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		#change_scene.call_deferred("island")
		await get_tree().process_frame
		change_scene("island")
		print("Server Starting World")
		
func clear_scene():
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()

# Call this function deferred and only on the main authority (server).
func change_scene(scene_alias : String): # scene: PackedScene
	# Remove old level if any.
	#await get_tree().process_frame
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(load(scene_lookup[scene_alias]).instantiate())

# The server can restart the level by pressing HOME.
#func _input(event):
	#if not multiplayer.is_server():
		#return
	#if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		#change_level.call_deferred(load("res://scenes/world/world.tscn"))
