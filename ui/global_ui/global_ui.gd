extends CanvasLayer

@onready var n_background = $ColorRect

func toggle_background(shown := true) -> void:
	self.n_background.visible = shown
