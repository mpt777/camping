extends Resource
class_name ItemData

@export var world_scene : PackedScene
@export var inventory_scene : PackedScene

@export var title : String
@export var description : String
@export var price : int

func to_world():
	pass

func to_inventory():
	pass
