extends Node3D
class_name Minigame

var player : Player

func constructor(m_player: Player) -> Minigame:
	self.player = m_player
	return self

func enter() -> void:
	pass
	
func exit() -> void:
	pass
