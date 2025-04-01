extends Resource
class_name PlayerData

var network_id : int
var name : String

var characters = 'abcdefghijklmnopqrstuvwxyz'

func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
	
func constructor(m_name: String = "") -> PlayerData:
	self.network_id = -1
	self.name = m_name
	if not self.name:
		self.name = generate_word(characters, 10)
	return self

func serialize() -> Dictionary:
	return {
		'network_id': self.network_id,
		'name': self.name,
	}
	
static func deserialize(data: Dictionary) -> PlayerData:
	var playerData : PlayerData = PlayerData.new().constructor(data["name"])
	playerData.network_id = data["network_id"]
	return playerData
