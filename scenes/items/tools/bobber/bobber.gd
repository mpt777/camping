extends Boyant
class_name Bobber

signal EnteredWater
signal HitWorld

@onready var fish_spawner : Node3D = $Spawner

func _ready() -> void:
	super()
	self.ready.connect(on_ready)

func on_ready() -> void:
	var auth = self.get_parent().get_multiplayer_authority()
	self.set_multiplayer_authority(auth)

func add_fish(fish_data : FishData):
	var node : FishWorld = fish_data.to_world_instance()
	node.set_multiplayer_authority(self.get_multiplayer_authority())
	fish_spawner.add_child(node, true)
	
	
func remove_fish():
	for child in fish_spawner.get_children():
		child.queue_free()

func _physics_process(_delta):
	if !self.top_level:
		return
	super(_delta)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is Water:
		self.water = area
		self.EnteredWater.emit()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area is Water:
		self.water = null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if self.water:
		return
	var layer = body.get_collision_layer()
	if layer & 1:
		self.HitWorld.emit()
