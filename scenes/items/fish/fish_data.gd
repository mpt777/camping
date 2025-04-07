extends ItemData
class_name FishData

@export var difficulty : int
@export var rarity : int
@export var water : Array[Enums.WaterType]


func to_world():
	if not self.world_scene:
		return 
	return
