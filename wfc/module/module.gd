extends Node3D
class_name WFCModule

@onready var body : StaticBody3D = $StaticBody3D
@onready var shape : CollisionShape3D = $StaticBody3D/CollisionShape3D
var mesh : ArrayMesh
var prototype : Dictionary

func set_mesh(new_mesh: ArrayMesh, p_scale: Vector3):
	mesh = new_mesh
	$mesh_instance.mesh = mesh
	scale = p_scale
	#await get_tree().process_frame
	shape.shape = mesh.create_trimesh_shape()
	
