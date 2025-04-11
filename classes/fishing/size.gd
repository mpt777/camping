extends Resource
class_name FishingSize

var value : int

func constructor(m_value : int) -> FishingSize:
	self.value = m_value
	return self
	
func get_value() -> float:
		return {
		1: 0.5,
		2: 0.75,
		3: 1,
		4: 2,
		5: 5,
	}[self.value]
	
func get_difficulty() -> float:
	return {
		1: 0.5,
		2: 0.75,
		3: 1,
		4: 2,
		5: 5,
	}[self.value]
