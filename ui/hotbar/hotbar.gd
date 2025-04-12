extends Control
class_name HotbarUI

@onready var n_slots = $HBoxContainer
@export var hotbar : Hotbar3D
@export var active_index := 1

signal Updated

func _ready():
	self.update()
	
func get_number_key(scancode: int) -> int:
	match scancode:
		KEY_1: return 1
		KEY_2: return 2
		KEY_3: return 3
		KEY_4: return 4
		KEY_5: return 5
		KEY_6: return 6
		KEY_7: return 7
		KEY_8: return 8
		KEY_9: return 9
		_:
			return -1
		
func _input(event: InputEvent) -> void:
	if !self.is_multiplayer_authority():
		return
	if event is InputEventKey and event.pressed:
		var number = get_number_key(event.keycode)
		if number != -1 and number <= n_slots.get_child_count():
			#self.set_index.rpc(number)
			self.set_index(number)

#@rpc("any_peer", "call_local", "reliable", 2)
func set_index(amount : int):
	self.active_index =amount
	#self.update.rpc()
	self.update()
	
func add_index(amount : int):
	self.set_index(self.active_index + amount)
	
func active_slot():
	return self.n_slots.get_child(self.active_index-1)
	
func set_item_data(idx : int, item_data : ItemData) -> void:
	for child in self.n_slots.get_children():
		child = child as ItemInventoryStandard
		if child.item_data == item_data:
			child.set_item_data(null)
	self.n_slots.get_child(idx -1).set_item_data(item_data)
	self.update()
	
#@rpc("any_peer", "call_local", "reliable", 2)
func update():
	self.hotbar.clear()
	var n_slot : ItemInventoryStandard = self.active_slot()
	if not n_slot.item_data:
		return
	if not n_slot.item_data.to_world():
		return
	self.hotbar.add_item(n_slot.item_data.to_world_instance())
