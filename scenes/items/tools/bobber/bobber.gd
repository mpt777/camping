extends Boyant
class_name Bobber

@onready var fish_spawner : Node3D = $Spawner
@onready var n_line_marker : Marker3D = %LineMarker

signal HitWorld

func _ready() -> void:
	super()
	self.ready.connect(on_ready)

func on_ready() -> void:
	self.set_multiplayer_authority(Utils.parents(self).filter(func (x): return x is Player)[0].player)

func add_fish(fish_data : FishData):
	var node : FishWorld = fish_data.to_world_instance()
	node.set_multiplayer_authority(self.get_multiplayer_authority())
	fish_spawner.add_child(node, true)

func reset():
	self.top_level = true
	self.global_position = self.global_position
	self.freeze = false
	self.angular_velocity = Vector3.ZERO

	
func remove_fish():
	for child in fish_spawner.get_children():
		child.queue_free()

func _physics_process(_delta):
	if !self.top_level:
		return
	super(_delta)
	self.rotation_degrees = Vector3.ZERO
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if self.water:
		return
	var layer = body.get_collision_layer()
	if layer & 1:
		print("hit!")
		self.HitWorld.emit()
