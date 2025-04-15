extends Node3D
class_name FishWorld

@export var fish_data : FishData
@export var s_fish_data : Dictionary:
	set(value):
		if !is_multiplayer_authority():
			self.fish_data = FishData.deserialize(value)
			self.render()
		s_fish_data = value
		
@onready var n_sprite : Sprite3D = $Sprite3D

func constructor(m_fish_data: FishData) -> FishWorld:
	self.fish_data = m_fish_data
	return self
	
func _ready() -> void:
	self.render()
	if self.fish_data:
		self.s_fish_data = self.fish_data.serialize()
	#if !self.is_multiplayer_authority():
		#self.constructor_request.rpc_id(self.get_multiplayer_authority())
	

func render() -> void:
	if self.n_sprite and self.fish_data:
		var x = self.fish_data.item_type.get_image()
		self.n_sprite.texture = self.fish_data.item_type.get_image()
	
