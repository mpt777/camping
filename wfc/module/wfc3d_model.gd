extends Resource
class_name WFC3D_Model

const MESH_NAME := "mesh_name"
const MESH_ROT := "mesh_rotation"
const NEIGHBOURS := "valid_neighbours"
const CONSTRAIN_TO := "constrain_to"
const CONSTRAIN_FROM := "constrain_from"
const CONSTRAINT_BOTTOM := "bot"
const CONSTRAINT_TOP := "top"
const WEIGHT := "weight"


const pX := 0
const pY := 1
const nX := 2
const nY := 3
const pZ := 4
const nZ := 5

var direction_to_index = {
	Vector3.LEFT : 2,
	Vector3.RIGHT : 0,
	Vector3.FORWARD : 1, # should be 3?
	Vector3.BACK : 3, # should be 1?
	Vector3.UP : 4,
	Vector3.DOWN : 5
}

var wave_function : Array  # Grid of modules containing prototypes
var size : Vector3
var stack : Array # modifable cache
var _stack : Array # copied and pasted on init

var cached_prototypes : Dictionary


func initialize(new_size : Vector3, all_prototypes : Dictionary) -> void:
	self.cached_prototypes = all_prototypes
	self.wave_function = []
	self._stack = self.stack
	
	size = new_size
	for _z in range(size.z):
		var y = []
		for _y in range(size.y):
			var x = []
			for _x in range(size.x):
				x.append(cached_prototypes.duplicate())
			y.append(x)
		wave_function.append(y)


func is_collapsed() -> bool:
	for z in wave_function:
		for y in z:
			for x in y:
				if len(x) > 1:
					return false
	return true


func get_possibilities(coords : Vector3) -> Dictionary:
	return wave_function[coords.z][coords.y][coords.x]


func get_possible_neighbours(coords : Vector3, dir : Vector3):
	var valid_neighbours = []
	var prototypes = get_possibilities(coords)
	var dir_idx = direction_to_index[dir]
	for prototype in prototypes:
		var neighbours = prototypes[prototype][NEIGHBOURS][dir_idx]
		for n in neighbours:
			if not n in valid_neighbours:
				valid_neighbours.append(n)
	return valid_neighbours


func collapse_coords_to(coords : Vector3, prototype_name : String):
	var prototype = wave_function[coords.z][coords.y][coords.x][prototype_name]
	wave_function[coords.z][coords.y][coords.x] = {prototype_name : prototype}


func collapse_at(coords : Vector3) -> void:
	var possible_prototypes = wave_function[coords.z][coords.y][coords.x]
	var selection = weighted_choice(possible_prototypes)
	var prototype = possible_prototypes[selection]
	possible_prototypes = {selection : prototype}
	wave_function[coords.z][coords.y][coords.x] = possible_prototypes
	

func weighted_choice(prototypes: Dictionary) -> String:
	var proto_weights = {}
	for p in prototypes:
		var w = prototypes[p][WEIGHT]
		w += randf_range(-1.0, 1.0)
		proto_weights[w] = p
	var weight_list = proto_weights.keys()
	weight_list.sort()
	return proto_weights[weight_list[-1]]
		

func collapse() -> void:
	var coords = get_min_entropy_coords()
	collapse_at(coords)


func constrain(coords : Vector3, prototype_name : String) -> void:
	wave_function[coords.z][coords.y][coords.x].erase(prototype_name)


func get_entropy(coords : Vector3) -> int:
	return len(wave_function[coords.z][coords.y][coords.x])


func get_min_entropy_coords() -> Vector3:
	var min_entropy : float
	var coords : Vector3
	for z in range(size.z):
		for y in range(size.y):
			for x in range(size.z):
				var entropy = get_entropy(Vector3(x, y, z))
				if entropy > 1:
					entropy += randf_range(-0.1, 0.1)
					
					if not min_entropy:
						min_entropy = entropy
						coords = Vector3(x, y, z)
					elif entropy < min_entropy:
						min_entropy = entropy
						coords = Vector3(x, y, z)
	return coords


func iterate() -> void:
	var coords = get_min_entropy_coords()
	collapse_at(coords)
	propagate(coords)


func propagate(co_ords, single_iteration:=false) -> void:
	if co_ords:
		_stack.append(co_ords)
	while len(_stack) > 0:
		var cur_coords = _stack.pop_back()

		# Iterate over each adjacent cell to this one
		for d in valid_dirs(cur_coords):
			
			var other_coords = (cur_coords + d)
			var possible_neighbours = get_possible_neighbours(cur_coords, d)
			var other_possible_prototypes = get_possibilities(other_coords).duplicate()
			
			if len(other_possible_prototypes) == 0:
				continue
			
			for other_prototype in other_possible_prototypes:
				if not other_prototype in possible_neighbours:
					constrain(other_coords, other_prototype)
					if not other_coords in _stack:
						_stack.append(other_coords)
		if single_iteration:
			break


func valid_dirs(coords: Vector3) -> Array[Vector3]:
	var x : int = coords.x
	var y : int= coords.y
	var z : int= coords.z
	
	var width : int = size.x
	var height : int = size.y
	var length :int = size.z
	var dirs : Array[Vector3] = []
	
	if x > 0: dirs.append(Vector3.LEFT)
	if x < width-1: dirs.append(Vector3.RIGHT)
	if y > 0: dirs.append(Vector3.DOWN)
	if y < height-1: dirs.append(Vector3.UP)
	if z > 0: dirs.append(Vector3.FORWARD)
	if z < length-1: dirs.append(Vector3.BACK)
	
	return dirs
