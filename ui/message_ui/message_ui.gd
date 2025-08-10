extends Control
class_name MessageUI

var message : String 
var color : Color

@onready var n_label : Label = $Label

func constructor(m_message : String, m_color: Color = Color.WHITE) -> MessageUI:
	self.message = m_message
	self.color = m_color
	return self
	
func _on_ready():
	self.set_multiplayer_authority(self.get_parent().get_multiplayer_authority())
	
func _ready() -> void:
	self.ready.connect(_on_ready)
	
func render() -> void:
	self.n_label.text = self.message
	
