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
	self.player.position = self.spawn_position
	self.player.name = self.name
	self.player.player = int(self.name)
	self.player.player_data = self.player_data

	player.constructor_node()
	
func _enter_tree() -> void:
	$".".set_multiplayer_authority(name.to_int())
