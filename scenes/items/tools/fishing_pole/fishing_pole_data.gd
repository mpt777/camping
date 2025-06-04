extends ItemData
class_name FishingPoleData

#@export var fishing_pole_type : ItemTypeData

func can_sell() -> bool:
	return false

func serialize() -> Dictionary:
	var data := super()
	data["content_type"] = "FishingPoleData"
	return data
