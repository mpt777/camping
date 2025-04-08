extends ItemInventory
class_name ItemInventoryStandard

@onready var n_popup : Popover = $PopupPanel
@onready var n_texture : TextureRect = $TextureRect

func popover_position() -> Vector2:
	return self.global_position + Vector2(self.size.x, 0)
	
func _ready():
	self.n_popup.set_heading(self.item_data.title)
	self.n_popup.set_description(self.item_data.description)
	self.n_popup.set_price(str(self.item_data.price))
	
	self.n_texture.texture = self.item_data.get_image()
	
func _on_mouse_entered() -> void:
	n_popup.display(true, self.popover_position())


func _on_mouse_exited() -> void:
	n_popup.display(false, self.popover_position())
