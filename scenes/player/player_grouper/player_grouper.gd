extends Node3D
class_name PlayerGrouper

var player_data : PlayerData
@onready var player : Player = $Player
@onready var player_global : PlayerGlobal = $PlayerGlobal

var spawn_position := Vector3.ZERO

func constructor(m_player_data : PlayerData):
	self.player_data = m_player_data
	return self
	
func _ready() -> void:
	if is_multiplayer_authority():
		GlobalUI.toggle_background(true)
		var vignette : Vignette = Game.VIGNETTE.instantiate().full_constructor(Vector2(0.5,0.5), false, true)
		await get_tree().process_frame
		GlobalUI.toggle_background(false)
		
	self.player.position = self.spawn_position
	self.player.name = self.name
	self.player.player = int(self.name)
	self.player.player_data = self.player_data

	player.constructor_node()
	
func _enter_tree() -> void:
	$".".set_multiplayer_authority(name.to_int())
