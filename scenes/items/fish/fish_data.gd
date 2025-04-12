extends ItemData
class_name FishData

@export var quality : FishingQuality
@export var size : FishingSize
@export var fish_type : FishType


func constructor(m_fish_type : FishType) -> FishData:
	self.fish_type = m_fish_type
	self.title = self.fish_type.title
	self.description = self.fish_type.description
	
	self.quality = FishingQuality.new().constructor(randi_range(1, 5))
	self.size = FishingSize.new().constructor(randi_range(1, 5))
	self.price = self.get_price()
	
	return self

func get_price() -> float:
	return self.fish_type.default_price * self.quality.get_value() * self.size.get_value()
	
func get_difficulty(base : float) -> int: 
	return int(base * self.quality.get_difficulty() * self.size.get_difficulty())
	
func get_difficulty_breadth() -> float:
	return get_difficulty(self.fish_type.difficulty_breadth) 

func get_difficulty_depth() -> float:
	return get_difficulty(self.fish_type.difficulty_depth)
	
####################################################################################################

func get_image() -> Texture2D:
	return self.fish_type.get_image()
	
func to_inventory() -> PackedScene:
	return self.fish_type.to_inventory()
	
func to_world() -> PackedScene:
	return load("res://scenes/items/fish/world/fish_world.tscn")
	
func to_world_instance():
	return self.to_world().instantiate().constructor(self)
	
	
	
################################################################

func serialize() -> Dictionary:
	return {
		'fish_type': self.fish_type.serialize(),
	}
	
static func deserialize(data: Dictionary) -> FishData:
	var obj : FishData = FishData.new().constructor(
		FishType.deserialize(data["fish_type"]),
	)
	return obj
