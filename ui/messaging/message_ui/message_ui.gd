extends Control
class_name MessageUI

var message : Message 

@onready var n_label : Label = %Label
@onready var n_sender : Label = %Sender

func constructor(m_message : Message) -> MessageUI:
	self.message = m_message
	return self
	
func _on_ready():
	self.set_multiplayer_authority(self.get_parent().get_multiplayer_authority())
	
func _ready() -> void:
	self.ready.connect(_on_ready)
	
func render() -> void:
	self.n_label.text = self.message.message
	
	if self.message.from in Game.players:
		var player : PlayerData = Game.players[self.message.from]
		self.n_sender.text = player.name
	
