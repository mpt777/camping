extends PanelContainer
class_name Popover

@onready var n_title : Label =  %Title
@onready var n_description : Label =  %Description
@onready var n_price : Label = %Price

func popover_position(rect: Rect2) -> Vector2:
	if !is_inside_tree():
		return Vector2.ZERO
	var screen_size := get_viewport_rect().size
	
	# Use minimum size if actual size is zero
	var popup_size := self.size
	if popup_size == Vector2.ZERO:
		popup_size = self.get_combined_minimum_size()
	
	# Start centered horizontally
	var pos := rect.position + Vector2((rect.size.x - popup_size.x) / 2.0, 0)
	
	# Above if not enough space below
	if rect.position.y + rect.size.y + popup_size.y > screen_size.y:
		pos.y -= popup_size.y
	else:
		pos.y += rect.size.y
	
	# Clamp
	pos.x = clamp(pos.x, 0, screen_size.x - popup_size.x)
	pos.y = clamp(pos.y, 0, screen_size.y - popup_size.y)
	
	return pos
	
func display(m_visible:=true, rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)):
	self.visible = m_visible
	self.global_position = self.popover_position(rect)

func set_heading(m_title: String) -> void:
	self.n_title.text = m_title

func set_description(m_title: String) -> void:
	self.n_description.text = m_title
	
func set_price(m_title: String) -> void:
	self.n_price.text = str(m_title)
