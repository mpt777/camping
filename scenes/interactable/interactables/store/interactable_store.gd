extends Interactable
class_name InteractableStore

@onready var n_menu : CanvasLayer = $CanvasLayer
@onready var n_sell : Sell = $CanvasLayer/Sell

func enter():
	self.n_sell.constructor(self.player)
	self.n_sell.constructor_node()
	
func exit():
	super()
