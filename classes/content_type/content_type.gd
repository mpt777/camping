extends Node

var register = {
	"ItemData": ItemData,
	"FishData": FishData
}

func get_content_type(string : String):
	return self.register[string]
