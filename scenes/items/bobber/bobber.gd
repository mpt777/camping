extends RigidBody3D
class_name Bobber

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
#@onready var water = get_node('/root/Main/Water')

@onready var probes = $ProbeContainer.get_children()
var water = null

var submerged := false

func set_uuid():
	return
	#self.name = Uuid.v4()

func _physics_process(delta):
	submerged = false
	if not water:
		return
	
	for p in probes:
		var depth = (water.get_height(p.global_position) - p.global_position.y)
		#self.global_position.y = water.get_height(p.global_position)
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, p.global_position - global_position)
			

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is Water:
		self.water = area
