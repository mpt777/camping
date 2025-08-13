extends RigidBody3D
class_name Boyant

@export var syncable := true
@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
#@onready var water = get_node('/root/Main/Water')

@export var probes_container : Node3D
var probes

var water = null
var submerged : bool = false

func _ready():
	probes = self.probes_container.get_children()

func _physics_process(_delta):
	submerged = false
	if not water:
		return
	
	for p in probes:
		var depth = (water.get_height(p.global_position) - p.global_position.y)
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
		
func _on_area_3d_area_exited(area: Area3D) -> void:
	if area is Water:
		self.water = null


func _on_body_entered(_body: Node) -> void:
	pass # Replace with function body.
