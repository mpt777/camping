extends ItemTypeData
class_name FishType

@export var default_price : int = 1
@export_range(1, 100) var difficulty_depth : int = 1
@export_range(1, 100) var difficulty_breadth : int = 1
@export var rarity : int = 1
@export var water : Array[Enums.WaterType]


func get_image() -> Texture2D:
	return self.image
	
func to_world() -> PackedScene:
	return load("res://scenes/items/fish/world/fish_world.tscn")
	
func to_inventory() -> PackedScene:
	return load("res://scenes/items/meta/item_inventory/standard/item_inventory_standard.tscn")


################################################################

#func serialize() -> Dictionary:
	#return {
		#'image': self.image.resource_path,
	#}
	#
#static func deserialize(data: Dictionary) -> FishType:
	#var obj : FishType = FishType.new()
	#obj.image = load(data["image"])
	#return obj
