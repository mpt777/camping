extends Resource
class_name PlayerData

var name : String
var money : int = 0
var experience : int = 0

var inventory : Dictionary = {}
var hotbar : Dictionary = {}

var characters = 'abcdefghijklmnopqrstuvwxyz'

func generate_word(chars, length):
	var word: String = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
	
func constructor(m_name: String = "") -> PlayerData:
	self.name = m_name
	if not self.name:
		self.name = generate_word(characters, 10)
	return self
	
	
####################################################################################################


static func save_path(n : String) -> String:
	return "player_" + n + ".save"
	
func serialize() -> Dictionary:
	return {
		'name': self.name,
		'inventory': self.inventory,
		'hotbar': self.hotbar,
		"money": self.money
	}
	
func serialize_update(data: Dictionary) -> PlayerData:
	self.name = data["name"]
	return self
	
static func deserialize(data: Dictionary) -> PlayerData:
	var obj : PlayerData = PlayerData.new().constructor(data["name"])
	obj.inventory = data["inventory"]
	obj.hotbar = data["hotbar"]
	obj.money = data.get("money", 0.0)
	return obj
