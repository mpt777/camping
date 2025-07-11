extends PlayerInput
class_name PlayerInputCamera

var mouse_modes = [
	Input.MOUSE_MODE_CAPTURED,
	#Input.MOUSE_MODE_CONFINED,
	Input.MOUSE_MODE_VISIBLE  
]

var mouse_mode_index : int = 0


func code() -> String:
	return "camera"
	
func _ready():
	self.set_mouse_mode(mouse_mode_index)

func set_mouse_mode(p_mouse_mode_index):
	var mouse_mode = self.mouse_modes[p_mouse_mode_index]
	Input.set_mouse_mode(mouse_mode)
	self.body.mouse_mode = mouse_mode
	
func _input(event: InputEvent) -> void:
	if self.is_valid():
		if event.is_action_pressed("ui_cancel"):
			mouse_mode_index += 1
			mouse_mode_index = (mouse_mode_index % len(self.mouse_modes))
			self.set_mouse_mode(mouse_mode_index)
