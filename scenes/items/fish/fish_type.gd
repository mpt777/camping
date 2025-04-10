extends Resource
class_name FishType


@export var image : Texture2D
@export var title : String
@export var description : String

@export var default_price : int = 1
@export_range(1, 100) var difficulty_depth : int = 1
@export_range(1, 100) var difficulty_breadth : int = 1
@export var rarity : int = 1
@export var water : Array[Enums.WaterType]


func get_image() -> Texture2D:
	return self.image
	
func to_inventory() -> PackedScene:
	return load("res://scenes/items/meta/item_inventory/standard/item_inventory_standard.tscn")
