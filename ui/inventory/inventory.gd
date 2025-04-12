extends Control
class_name Inventory

@onready var n_container : GridContainer = $GridContainer

signal AddToHotbar

func get_number_key(scancode: int) -> int:
	match scancode:
		KEY_1: return 1
		KEY_2: return 2
		KEY_3: return 3
		KEY_4: return 4
		KEY_5: return 5
		_:
			return -1
		
func _input(event: InputEvent) -> void:
	if !self.is_multiplayer_authority():
		return
	if event is InputEventKey and event.pressed:
		var number = get_number_key(event.keycode)
		var current_item_inventory = self.get_current_item_inventory()
		if number != -1 and current_item_inventory and current_item_inventory.item_data:
			self.AddToHotbar.emit(number, current_item_inventory.item_data)
			
func get_current_item_inventory() -> ItemInventoryStandard:
	for child in self.n_container.get_children():
		child = child as ItemInventoryStandard
		if child.active:
			return child
	return
			
func add_item(item_data : ItemData) -> void:
	var item_inventory = item_data.to_inventory().instantiate()
	item_inventory.constructor(item_data)
	n_container.add_child(item_inventory, true)
	item_inventory = item_inventory as ItemInventoryStandard
	item_inventory.custom_minimum_size = Vector2(100,100)
