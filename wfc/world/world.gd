extends Node3D
class_name WFCWorld


@export var size = Vector3(8, 3, 8)
const unit_size = 10.0
const mesh_string = "res://wfc/meshes/%s.tres"

var enabled = false
var my_seed = 102

var wfc : WFC3D_Model
var meshes : Array
var coords : Vector3

@export var mesh_container : Node3D

@onready var thread:= Thread.new()

@onready var module = preload("res://wfc/module/Module.tscn")
signal Finished


func _ready():
	pass

func _exit_tree():
	self.thread.wait_to_finish()

func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		#my_seed = randi()
		#my_seed += 1
		print(my_seed)
		generate()
		

#func test():
	#var update = false  # change to TRUE to re-render every iteration
	#clear_meshes()
	#seed(hash(str(my_seed)))
	#var prototypes = load_prototype_data()
	#wfc = WFC3D_Model.new()
	#add_child(wfc)
	#wfc.initialize(size, prototypes)
	#
	#apply_custom_constraints()  # see definition
	#
	#if update:
		#while not wfc.is_collapsed():
			#wfc.iterate()
			#clear_meshes()
			#visualize_wave_function()
			#await get_tree().process_frame
		#clear_meshes()
	#else:
		#regen_no_update()
		#
	#visualize_wave_function()
#
#
#func regen_no_update():
	#while not wfc.is_collapsed():
		#wfc.iterate()
		#
	#visualize_wave_function()
	#if len(meshes) == 0:
		#my_seed += 1
		#test()
		
		
func generate():
	if thread.is_started():
		thread.wait_to_finish()
	clear_meshes()
	seed(hash(str(my_seed)))
	
	thread.start(
		func(): 
			print("started")
			#if wfc:
				#wfc.initialize(size, wfc.cached_prototypes)
			#else:
			wfc = WFC3D_Model.new()
			print("init")
			wfc.initialize(size, load_prototype_data())
			print("constrain")
			#apply_custom_constraints()  # see definition
			
			print("enter iterate")
			while not wfc.is_collapsed():
				wfc.iterate()
				print("interate")
			call_deferred("visualize_wave_function")
			call_deferred("finalize")
			print("finalize")
	)
	
	
func finalize():
	Finished.emit()
	if thread.is_started():
		thread.wait_to_finish()

func apply_custom_constraints():
	# This function isn't covered in the video but what we do here is basically
	# go over the wavefunction and remove certain modules from specific places
	# for example in my Blender scene I've marked all of the beach tiles with
	# an attribute called "constrain_to" with the value "bot". This is recalled
	# in this function, and all tiles with this attribute and value are removed
	# from cells that are not at the bottom i.e., if y > 0: constrain.
	var add_to_stack = []
	
	for z in range(size.z):
		for y in range(size.y):
			for x in range(size.x):
				coords = Vector3(x, y, z)
				var protos = wfc.get_possibilities(coords)
				if y == size.y - 1:  # constrain top layer to not contain any uncapped prototypes
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.pZ]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if y > 0:  # everything other than the bottom
					for proto in protos.duplicate():
						var custom_constraint = protos[proto][WFC3D_Model.CONSTRAIN_TO]
						if custom_constraint == WFC3D_Model.CONSTRAINT_BOTTOM:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if y < size.y - 1:  # everything other than the top
					for proto in protos.duplicate():
						var custom_constraint = protos[proto][WFC3D_Model.CONSTRAIN_TO]
						if custom_constraint == WFC3D_Model.CONSTRAINT_TOP:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if y == 0:  # constrain bottom layer so we don't start with any top-cliff parts at the bottom
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.nZ]
						var custom_constraint = protos[proto][WFC3D_Model.CONSTRAIN_FROM]
						if (not "p-1" in neighs) or (custom_constraint == WFC3D_Model.CONSTRAINT_BOTTOM):
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if x == size.x - 1: # constrain +x
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.pX]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if x == 0: # constrain -x
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.nX]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if z == size.z - 1: # constrain +z
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.nY]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if z == 0: # constrain -z
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.pY]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				
	
	wfc.propagate(false, false)


func load_prototype_data():
	var file = FileAccess.open("res://wfc/meshes/prototype_data.json", FileAccess.READ)
	var text = file.get_as_text()
	var prototypes = JSON.new().parse_string(text)
	return prototypes


func visualize_wave_function(only_collapsed=true):
	for z in range(size.z):
		for y in range(size.y):
			for x in range(size.x):
				var prototypes = wfc.wave_function[z][y][x]
				
				if only_collapsed:
					if len(prototypes) > 1:
						continue
				
				for prototype in prototypes:
					var dict = wfc.wave_function[z][y][x][prototype]
					var mesh_name = dict[wfc.MESH_NAME]
					var mesh_rot = dict[wfc.MESH_ROT]
					
					if mesh_name == "-1":
						continue
					
					var inst : WFCModule = module.instantiate()
					meshes.append(inst)
					mesh_container.add_child(inst)
					var mesh = load(mesh_string % mesh_name)
					inst.set_mesh(mesh, Vector3(1,1,1) * self.unit_size)
					inst.rotate_y((PI/2) * mesh_rot)
					inst.position = Vector3((x*unit_size), y*unit_size, z*unit_size)
					inst.prototype = {prototype: dict}


func clear_meshes():
	for mesh in meshes:
		mesh.queue_free()
	meshes = []
