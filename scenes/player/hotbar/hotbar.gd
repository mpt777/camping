extends Node3D
class_name Hotbar

func active_item() -> Item:
	return get_children()[0] as Item
