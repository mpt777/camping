extends Node

var register = {
	"ItemData": ItemData,
	"FishData": FishData
}

func get_content_type(str : String):
	return self.register[str]
