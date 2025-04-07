extends Control
class_name Masher

@export var clicks : int = 1
@export_range(0, 1) var percentage : float = 0.5

@onready var n_label : Label = %Label

func constructor(m_clicks, m_percentage) -> Masher:
	self.clicks = m_clicks
	self.percentage = m_percentage
	return self
	
func _ready() -> void:
	self.render()
	self.anchor_left = self.percentage

func click(value : int) -> void:
	
	self.clicks -= value
	self.render()
	if self.clicks <= 0:
		self.queue_free()
	
func render() -> void:
	n_label.text = str(self.clicks)
