extends Control
class_name PeerControls

@export var player_data_serialized : Dictionary:
	get:
		return player_data.serialize()
	set(value):
		if not player_data:
			player_data = PlayerData.deserialize(value)
		player_data.serialize_update(value)
		
@export var player_data : PlayerData
@onready var n_label : Label = $HBoxContainer/Label

func constructor(m_player_data: PlayerData) -> PeerControls:
	self.player_data = m_player_data
	return self
	
func _ready():
	self.update_text()

func update_text():
	if not self.player_data:
		return
	n_label.text = str(self.player_data.name) + str(self.player_data.network_id)
