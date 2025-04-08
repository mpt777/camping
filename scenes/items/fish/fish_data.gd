extends ItemData
class_name FishData

@export var fish_type : FishType

func constructor(m_fish_type : FishType) -> FishData:
	self.fish_type = m_fish_type
	self.title = self.fish_type.title
	self.description = self.fish_type.description
	self.price = 30
	return self

func get_image() -> Texture2D:
	return self.fish_type.get_image()
	
func to_inventory() -> PackedScene:
	return self.fish_type.to_inventory()
