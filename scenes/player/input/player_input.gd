extends Node
class_name PlayerInput

@export var active : bool = true
@export var body : Player

func code() -> String:
	return ""

func activate() -> void:
	self.active = true
	
func deactivate() -> void:
	self.active = true

func is_valid() -> bool:
	if not self.active:
		return false
	if not is_multiplayer_authority():
		return false
	return true

func process(delta: float) -> void:
	pass
	
func physics_process(delta: float) -> void:
	pass
