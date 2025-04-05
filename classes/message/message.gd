extends Resource
class_name Message

var message : String
var to : Array[int]
var from : int
var color : Color

func constructor(m_message: String, m_to: Array[int], m_from: int = -1, m_color : Color = Color.WHITE) -> Message:
	self.message = m_message
	self.to = m_to
	self.from = m_from
	if self.from < 0:
		self.from = Game.multiplayer.get_unique_id()
	self.color = m_color
	return self

func serialize() -> Dictionary:
	return {
		'message': self.message,
		'to': self.to,
		'from': self.from,
		'color': self.color,
	}
	
func serialize_update(data: Dictionary) -> Message:
	self.message = data["message"]
	self.to = data["to"]
	self.from = data["from"]
	self.color = data["color"]
	return self
	
static func deserialize(data: Dictionary) -> Message:
	var message : Message = Message.new().constructor(
		data["message"],
		data["to"],
		data["from"],
		data["color"],
	)
	return message
