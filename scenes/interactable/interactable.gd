extends Node3D
class_name Interactable

var player : Player

func constructor(p_player : Player) -> Interactable:
	self.player = p_player
	return self
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		self.exit()
		get_viewport().set_input_as_handled()
	
func enter():
	pass
	
func exit():
	self.queue_free()
	self.player.end_interact()
