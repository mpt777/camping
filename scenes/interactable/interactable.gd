extends Node3D
class_name Interactable

var player : Player

func constructor(p_player : Player) -> Interactable:
	self.player = p_player
	return self
	
func enter():
	pass
	
func exit():
	pass
