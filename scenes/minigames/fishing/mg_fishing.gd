extends Minigame
class_name MGFishing

@onready var n_good : ProgressBar = %BarGood
@onready var n_bad : ProgressBar = %BarBad

const time = 3
var is_held := false

func _input(event : InputEvent):
	if event.is_action_pressed("left_mouse"):
		self.is_held = true
	if event.is_action_released("left_mouse"):
		self.is_held = false
		
func _process(delta: float) -> void:
	if self.is_held:
		self.n_good.value += (delta * (100 / time))
		if self.n_good.value >= 100:
			self.player.add_money(10)
			self.exit()
			
func exit() -> void:
	super()
	self.queue_free()
	
