extends Node
class_name PlayerInput

@export var active : bool = true
@export var body : Player

func code() -> String:
	return ""

func activate() -> void:
	pass
	
func deactivate() -> void:
	pass
	
func set_active(a : bool) -> void:
	if a:
		self.active = true
		self.activate()
	else:
		self.deactivate()
		self.active = false

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
