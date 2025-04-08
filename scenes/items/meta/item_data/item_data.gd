extends Resource
class_name ItemData

@export var world_scene : PackedScene
@export var inventory_scene : PackedScene

@export var title : String
@export var description : String
@export var price : int

func to_world() -> PackedScene:
	return self.world_scene

func to_inventory() -> PackedScene:
	return self.inventory_scene
