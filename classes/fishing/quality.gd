extends Resource
class_name FishingQuality

var value : int

func constructor(m_value : int) -> FishingQuality:
	self.value = m_value
	return self
	
func get_value() -> float:
		return {
		1: 1,
		2: 1.5,
		3: 3.5,
		4: 6,
		5: 10,
	}[self.value]
	
func get_difficulty() -> float:
	return {
		1: 1,
		2: 2,
		3: 5,
		4: 10,
		5: 18,
	}[self.value]
