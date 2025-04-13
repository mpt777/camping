extends Resource
class_name ItemData

@export var world_scene : PackedScene
@export var inventory_scene : PackedScene

@export var image : Texture2D

@export var title : String
@export var description : String
@export var price : int

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
	
	
func serialize() -> Dictionary:
	var data = {
		"content_type": "ItemData",
		"title": self.title,
		"description": self.description,
		"price": self.price,
		"image": self.get_image().resource_path,
	}
	if self.to_world():
		data["world_scene"] = self.to_world().resource_scene_unique_id
	if self.to_inventory():
		data["inventory_scene"] = self.to_inventory().resource_scene_unique_id
	return data
	
	
func deserialize_instance(data: Dictionary) -> ItemData:
	self.title = data["title"]
	self.description = data["description"]
	self.price = data["price"]
	self.image = load(data["image"])
	
	if data.get("world_scene", ""):
		self.world_scene = load(data.get("world_scene", ""))
		
	if data.get("inventory_scene", ""):
		self.inventory_scene = load(data.get("inventory_scene", ""))

	return self
	
static func deserialize(data: Dictionary) -> ItemData:
	return ItemData.new().deserialize_instance(data)
