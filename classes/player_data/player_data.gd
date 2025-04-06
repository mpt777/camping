extends Resource
class_name PlayerData

var name : String
var money : int = 0
var exp : int = 0

var characters = 'abcdefghijklmnopqrstuvwxyz'

func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
	
func constructor(m_name: String = "") -> PlayerData:
	self.name = m_name
	if not self.name:
		self.name = generate_word(characters, 10)
	return self

func serialize() -> Dictionary:
	return {
		'name': self.name,
	}
	
func serialize_update(data: Dictionary) -> PlayerData:
	self.network_id = data["network_id"]
	self.name = data["name"]
	return self
	
static func deserialize(data: Dictionary) -> PlayerData:
	var playerData : PlayerData = PlayerData.new().constructor(data["name"])
	return playerData
