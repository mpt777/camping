extends Control
class_name Inventory

@onready var n_container : GridContainer = $GridContainer

func add_item(item_data : ItemData) -> void:
	var item_inventory = item_data.to_inventory().instantiate()
	item_inventory.constructor(item_data)
	n_container.add_child(item_inventory, true)
	item_inventory = item_inventory as ItemInventoryStandard
	item_inventory.custom_minimum_size = Vector2(100,100)
