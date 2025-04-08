extends Resource
class_name FishType


@export var image : Texture2D
@export var title : String
@export var description : String

@export var difficulty : int
@export var rarity : int
@export var water : Array[Enums.WaterType]


func get_image() -> Texture2D:
	return self.image
	
func to_inventory() -> PackedScene:
	return load("res://scenes/items/meta/item_inventory/standard/item_inventory_standard.tscn")
