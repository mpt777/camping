extends PlayerInput
class_name PlayerInputUI

func code() -> String:
	return "ui"

func _unhandled_input(event: InputEvent) -> void:
	if !is_valid():
		return
		
	if event.is_action_pressed("inventory"):
		body.n_ui.visible = !body.n_ui.visible
		if body.n_ui.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			body.set_input(["movement", "camera"], false)
			body.player_mesh.animate_to(Enums.ANIMATION.IDLE)
		else:
			Input.set_mouse_mode(self.body.mouse_mode)
			body.set_input(["movement", "camera"], true)
			#self.set_mouse_mode(self.mouse_mode_index)
