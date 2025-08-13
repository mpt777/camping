extends Node3D
class_name Hotbar3D

@export var player : Player
@onready var n_container : Node3D = $Container
#func _enter_tree() -> void:
	#$MultiplayerSpawner.set_multiplayer_authority(1)
	
func constructor() -> Hotbar3D:
	return self

func active_item() -> Item:
	return get_children()[0] as Item
	
	
func clear():
	for child in n_container.get_children():
		child.queue_free()
		
func add_item(node : Node) -> void:
	if !self.is_multiplayer_authority():
		return
	self.clear()
	print("Add Item ",self.player.player)
	node.set_multiplayer_authority(self.player.player)
	n_container.add_child(node, true)
	
	#node.constructor(self.player)
