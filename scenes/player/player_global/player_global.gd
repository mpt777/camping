extends Node3D
class_name PlayerGlobal

func _ready() -> void:
	pass

func _enter_tree() -> void:
	$".".set_multiplayer_authority(get_parent().name.to_int())
	
	if is_multiplayer_authority():
		Signals.AddProjectile.connect(_add_projectile)
	
func _add_projectile(node) -> void:
	self.add_child(node, true)
	
func _on_multiplayer_spawner_spawned(node: Node) -> void:
	node.set_multiplayer_authority(get_parent().name.to_int())
	print(multiplayer.get_unique_id() , " spawned ", node)
