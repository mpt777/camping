extends Node
class_name MultiplayerItem

func _enter_tree() -> void:
	self.get_parent().set_multiplayer_authority(self.get_parent().get_parent().get_multiplayer_authority())
