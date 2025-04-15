extends Resource
class_name ItemData

@export var item_type : ItemTypeData
@export var uuid : String

func _init():
	if not self.uuid:
		self.generate_uuid()

func set_item_type(m_item_type : ItemTypeData) -> ItemData:
	self.item_type = m_item_type
	return self
	
	
func get_title() -> String:
	return self.item_type.title
	
func get_description() -> String:
	return self.item_type.description
	
func get_price() -> float:
	return self.item_type.price

func get_image() -> Texture2D:
	return self.item_type.get_image()
	
func to_inventory() -> PackedScene:
	return self.item_type.to_inventory()
	
func to_world() -> PackedScene:
	return self.item_type.to_world()
	
func to_world_instance():
	return self.to_world().instantiate()
	
	
func generate_uuid():
	self.uuid = str(Uuid.v4())
	
func is_equal(item_data : ItemData) -> bool:
	if self.uuid and item_data.uuid:
		return self.uuid == item_data.uuid
	return false
	
#@export var world_scene : PackedScene
#@export var inventory_scene : PackedScene
#
#@export var image : Texture2D
#
#@export var title : String
#@export var description : String
#@export var price : int
#
#func get_image() -> Texture2D:
	#return self.image
#
#func to_world() -> PackedScene:
	#return self.world_scene
	#
#func to_world_instance():
	#return self.world_scene.instantiate()
#
#func to_inventory() -> PackedScene:
	#if not self.inventory_scene:
		#return load("res://scenes/items/meta/item_inventory/standard/item_inventory_standard.tscn")
	#return self.inventory_scene
	#
	#
func serialize() -> Dictionary:
	var data = {}
	data["item_type"] = str(ResourceLoader.get_resource_uid(self.item_type.resource_path))
	data["uuid"] = self.uuid
	return data

func deserialize_instance(data: Dictionary) -> ItemData:
	#uid://dy3lpf5uqnfs5
	self.item_type = load(ResourceUID.get_id_path(int(data["item_type"])))
	self.uuid = data["uuid"]
	return self
	
static func deserialize(data: Dictionary) -> ItemData:
	return ItemData.new().deserialize_instance(data)
