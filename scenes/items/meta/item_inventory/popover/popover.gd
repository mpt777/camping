extends PanelContainer
class_name Popover

@onready var n_title : Label =  %Title
@onready var n_description : Label =  %Description
@onready var n_price : Label = %Price

func display(m_visible:=true, m_position:= Vector2.ZERO):
	self.visible = m_visible
	self.global_position = m_position

func set_heading(m_title: String) -> void:
	self.n_title.text = m_title

func set_description(m_title: String) -> void:
	self.n_description.text = m_title
	
func set_price(m_title: String) -> void:
	self.n_price.text = str(m_title)
