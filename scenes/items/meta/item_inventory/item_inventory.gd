extends AspectRatioContainer
class_name ItemInventory

@export var item_data : ItemData
var title : String
var description : String
var image : Image
var price : int

func constructor(m_item_data : ItemData) -> ItemInventory:
	self.item_data = m_item_data
	return self

func get_image() -> Texture2D:
	return
