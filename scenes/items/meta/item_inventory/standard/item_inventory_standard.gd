extends ItemInventory
class_name ItemInventoryStandard

@onready var n_popup : Popover = %PopupPanel
@onready var n_texture : TextureRect = %TextureRect
var active := false

signal Clicked

#func popover_position() -> Vector2: ### Right
	#var screen_y := get_viewport_rect().size.y
	#var pos := self.global_position + Vector2(self.size.x, 0)
	#if self.global_position.y / screen_y > 0.8:
		#pos -= Vector2(0, self.n_popup.size.y - self.size.y)
	#return pos
	
func popover_position() -> Vector2:
	var viewport_rect := get_viewport_rect()
	var screen_size := viewport_rect.size
	
	# Start centered horizontally relative to this control
	var pos := self.global_position + Vector2((self.size.x - self.n_popup.size.x) / 2.0, 0)
	
	# If we're in the bottom half of the screen -> place above, else below
	if self.global_position.y > screen_size.y * 0.5:
		# Above
		pos.y -= self.n_popup.size.y
	else:
		# Below
		pos.y += self.size.y
	
	# Clamp to screen so popup never goes off
	pos.x = clamp(pos.x, 0, screen_size.x - self.n_popup.size.x)
	pos.y = clamp(pos.y, 0, screen_size.y - self.n_popup.size.y)
	
	return pos

	
func _ready():
	self.render()

func render():
	self.n_popup.set_heading("")
	self.n_popup.set_description("")
	self.n_popup.set_price("")
	self.n_texture.texture = null
	if not self.item_data:
		return 
	self.n_popup.set_heading(self.item_data.get_title())
	self.n_popup.set_description(self.item_data.get_description())
	self.n_popup.set_price(str(self.item_data.get_price()))
	
	self.n_texture.texture = self.item_data.get_image()
	
func set_item_data(m_item_data : ItemData = null):
	if (!m_item_data || !m_item_data.item_type):
		self.item_data = null
		self.render()
		return
	self.item_data = m_item_data
	self.render()
	
func _on_mouse_entered() -> void:
	if not self.item_data:
		return
	self.active = true
	n_popup.display(true, self.popover_position())

func _on_mouse_exited() -> void:
	self.active = false
	n_popup.display(false, self.popover_position())
	
	
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		Clicked.emit(self)
