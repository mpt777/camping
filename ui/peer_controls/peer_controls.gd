extends Control
class_name PeerControls

var player_data : PlayerData
@onready var n_label : Label = $HBoxContainer/Label

func constructor(m_player_data: PlayerData) -> PeerControls:
	self.player_data = m_player_data
	return self
	
func _ready():
	self.update_text()

func update_text():
	n_label.text = str(self.player_data.name) + str(self.player_data.network_id)
