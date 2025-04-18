extends Control
class_name Sell

var player : Player
@onready var n_container : GridContainer = $GridContainer


func constructor(p_player : Player) -> Sell:
	self.player = p_player
	return self
	
func _ready() -> void:
	pass
	
func constructor_node() -> void:
	for item in self.player.n_ui.n_inventory.n_container.get_children():
		self.add_item_data(item.item_data)
		
func add_item_data(item_data : ItemData):
	var item_inventory = item_data.to_inventory().instantiate()
	item_inventory.constructor(item_data)
	n_container.add_child(item_inventory, true)
	item_inventory = item_inventory as ItemInventoryStandard
	item_inventory.custom_minimum_size = Vector2(100,100)
	item_inventory.Clicked.connect(self.sell)
	
	
func sell(item_inventory : ItemInventoryStandard):
	item_inventory.queue_free()
	self.player.add_money(item_inventory.item_data.get_price())
	self.player.remove_item_from_inventory(item_inventory.item_data)
