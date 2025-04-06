extends Node3D
class_name Minigame

var player : Player

signal Entered
signal Exited

func constructor(m_player: Player) -> Minigame:
	self.player = m_player
	return self

func enter() -> void:
	self.Entered.emit()
	
func exit() -> void:
	self.Exited.emit()
