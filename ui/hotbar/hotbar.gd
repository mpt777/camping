extends Control
class_name HotbarUI

@onready var n_slots = $HBoxContainer
@export var hotbar : Hotbar3D
@export var active_index := 1

signal Updated

#func _ready():
	#self.update()
	
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
	
func set_item_data(idx : int, item_data : ItemData, p_update : bool = true) -> void:
	for child in self.n_slots.get_children():
		child = child as ItemInventoryStandard
		if child.item_data and child.item_data.is_equal(item_data):
			child.set_item_data(null)
	self.n_slots.get_child(idx -1).set_item_data(item_data)
	if p_update:
		self.update()
	
func remove_item(item_data : ItemData, p_update : bool = true) -> void:
	for child in self.n_slots.get_children():
		child = child as ItemInventoryStandard
		if child.item_data and child.item_data.is_equal(item_data):
			child.set_item_data(null)
			return
	if p_update:
		self.update()
	
#@rpc("any_peer", "call_local", "reliable", 2)
func update():
	print("Update")
	self.hotbar.clear()
	var n_slot : ItemInventoryStandard = self.active_slot()
	if not n_slot.item_data:
		return
	if not n_slot.item_data.to_world():
		return
	self.hotbar.add_item(n_slot.item_data.to_world_instance())
	
#####################################################################
	
func clear() -> void:
	for child in self.n_slots.get_children():
		child = child as ItemInventoryStandard
		child.set_item_data(null)
	
func serialize() -> Dictionary:
	var item_data : Array[Dictionary] = []
	
	for child in self.n_slots.get_children():
		child = child as ItemInventoryStandard
		if child.item_data:
			item_data.append(child.item_data.serialize())
		else:
			item_data.append({})
		
	return {
		"item_data": item_data
	}
	
func deserialize(data : Dictionary) -> void:
	var item_data =data.get("item_data", []) 
	if !item_data:
		return
	self.clear()
	
	for idx in len(item_data):
		var d : Dictionary = item_data[idx]
		if !d:
			continue
		var item
		if "content_type" in d:
			#var x = ContentType.get_content_type(d["content_type"])
			item = ContentType.get_content_type(d["content_type"]).new().deserialize_instance(d)
		else:
			item = ItemData.new().deserialize_instance(d)
		self.set_item_data(idx + 1, item, false)
