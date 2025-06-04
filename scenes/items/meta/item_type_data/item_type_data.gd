extends Resource
class_name ItemTypeData

@export var world_scene : PackedScene
@export var inventory_scene : PackedScene

@export var image : Texture2D

@export var title : String
@export var description : String
@export var price : int

func can_sell() -> bool:
	return true

func get_image() -> Texture2D:
	return self.image

func to_world() -> PackedScene:
	return self.world_scene
	
func to_world_instance():
	return self.world_scene.instantiate()

func to_inventory() -> PackedScene:
	if not self.inventory_scene:
		return load("res://scenes/items/meta/item_inventory/standard/item_inventory_standard.tscn")
	return self.inventory_scene
	
