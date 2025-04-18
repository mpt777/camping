extends ItemInventory
class_name ItemInventoryStandard

@onready var n_popup : Popover = %PopupPanel
@onready var n_texture : TextureRect = %TextureRect
var active := false

signal Clicked

func popover_position() -> Vector2:
	var screen_y := get_viewport_rect().size.y
	var pos := self.global_position + Vector2(self.size.x, 0)
	if self.global_position.y / screen_y > 0.8:
		pos -= Vector2(0, self.n_popup.size.y - self.size.y)
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
	self.item_data = m_item_data
	self.render()
	
func _on_mouse_entered() -> void:
	self.active = true
	n_popup.display(true, self.popover_position())

func _on_mouse_exited() -> void:
	self.active = false
	n_popup.display(false, self.popover_position())
	
	
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		Clicked.emit(self)
