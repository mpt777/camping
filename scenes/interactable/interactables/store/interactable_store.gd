extends Interactable
class_name InteractableStore

@onready var n_menu : CanvasLayer = $CanvasLayer
@onready var n_sell : Sell = $CanvasLayer/Sell
@onready var store_config : StoreConfig

func enter():
	self.n_sell.constructor(self.player)
	if self.store_config:
		self.n_sell.set_label(self.store_config.title)
	self.n_sell.constructor_node()
	
func exit():
	super()
