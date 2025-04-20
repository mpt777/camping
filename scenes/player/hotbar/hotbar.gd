extends Node3D
class_name Hotbar3D

@export var player : Player
#func _enter_tree() -> void:
	#$MultiplayerSpawner.set_multiplayer_authority(1)

func active_item() -> Item:
	return get_children()[0] as Item
	
	
func clear():
	for child in $Container.get_children():
		child.queue_free()
		
func add_item(node : Node) -> void:
	self.clear()
	$Container.add_child(node, true)
	node.set_multiplayer_authority(self.player.player)
	#node.constructor(self.player)


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	await get_tree().process_frame
	node.set_multiplayer_authority(self.player.player)
	#node.constructor(self.player)
