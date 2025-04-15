extends ItemData
class_name FishData

@export var quality : FishingQuality
@export var size : FishingSize
var price : float = 0.0


func constructor(m_fish_type : ItemTypeData) -> FishData:
	m_fish_type = m_fish_type as FishType
	self.item_type = m_fish_type
	#self.title = self.fish_type.title
	#self.description = self.fish_type.description
	
	self.quality = FishingQuality.new().constructor(randi_range(1, 5))
	self.size = FishingSize.new().constructor(randi_range(1, 5))
	self.price = self.set_price()
	
	return self

func set_price() -> float:
	return self.item_type.default_price * self.quality.get_value() * self.size.get_value()

func get_price() -> float:
	return self.price
	
func get_difficulty(base : float) -> int: 
	return int(base * self.quality.get_difficulty() * self.size.get_difficulty())
	
func get_difficulty_breadth() -> float:
	return get_difficulty(self.item_type.difficulty_breadth) 

func get_difficulty_depth() -> float:
	return get_difficulty(self.item_type.difficulty_depth)
	
####################################################################################################
	
func to_world() -> PackedScene:
	return load("res://scenes/items/fish/world/fish_world.tscn")
	
func to_world_instance():
	return self.to_world().instantiate().constructor(self)
	
	
	
################################################################

func serialize() -> Dictionary:
	var data := super()
	data["content_type"] = "FishData"
	data["price"] = self.price
	return data

func deserialize_instance(data: Dictionary) -> FishData:
	super(data)
	self.price = data["price"]
	return self
	
static func deserialize(data: Dictionary) -> FishData:
	return FishData.new().deserialize_instance(data)
