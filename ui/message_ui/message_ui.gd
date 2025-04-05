extends Control
class_name MessageUI

var message : String 
var color : Color

@onready var n_label : Label = $Label

func constructor(m_message : String, m_color: Color = Color.WHITE) -> MessageUI:
	self.message = m_message
	self.color = m_color
	return self
	

func _enter_tree() -> void:
	self.set_multiplayer_authority(self.get_parent().get_multiplayer_authority())
	
func render() -> void:
	self.n_label.text = self.message
	
