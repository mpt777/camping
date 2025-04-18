extends Control
class_name Inventory

const INVENTORY = preload("res://ui/inventory/inventory.tscn")

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
	
func remove_item(item_data : ItemData) -> void:
	for child in self.n_container.get_children():
		child = child as ItemInventoryStandard
		if child.item_data.is_equal(item_data):
			child.queue_free()
			return
	
func clear() -> void:
	for child in self.n_container.get_children():
		child.queue_free()
	
func serialize() -> Dictionary:
	var item_data : Array[Dictionary] = []
	
	for child in self.n_container.get_children():
		child = child as ItemInventoryStandard
		item_data.append(child.item_data.serialize())
		
	return {
		"item_data": item_data
	}
	
func deserialize(data : Dictionary) -> void:
	if !data.get("item_data", []):
		return
	self.clear()
	for d in data.get("item_data", []):
		if "content_type" in d:
			#var x = ContentType.get_content_type(d["content_type"])
			self.add_item(ContentType.get_content_type(d["content_type"]).new().deserialize_instance(d))
		else:
			self.add_item(ItemData.new().deserialize_instance(d))
