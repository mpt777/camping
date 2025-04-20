extends CanvasLayer

@onready var n_background = $ColorRect
@onready var n_vignette : Vignette = $Vignette

func _ready() -> void:
	self.n_vignette.visible = false

func toggle_background(shown := true) -> void:
	self.n_background.visible = shown
	
func transition_in():
	self.n_vignette.visible = true
	self.n_vignette.circle_in()
	
func transition_out():
	await self.n_vignette.circle_out()
	self.n_vignette.visible = false
