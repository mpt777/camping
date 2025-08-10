extends Node
class_name UtilsClass

func closest_node(origin: Vector3, nodes : Array) -> Node3D:
	var nearest : float = INF
	var closest_player : Node3D = null
	for node in nodes:
		var distance := origin.distance_squared_to(node.global_position)
		if distance and distance < nearest:
			nearest = distance
			closest_player = node
	return closest_player

func closest_node_in_group(origin: Vector3, group_name: String, exclude=null) -> Node3D:
	var nodes := get_tree().get_nodes_in_group(group_name)
	if exclude:
		nodes = nodes.filter(func(x): return x != exclude)
	return self.closest_node(origin, nodes)
	
func remove_nulls(arr) -> Array:
	return arr.filter(func(x): return x != null)
	
func remove_item(array, item) -> bool:
	if not item in array:
		return false
	var to_remove = find_item(array, item)
	if to_remove > -1:
		array.remove_at(to_remove)
		return true
	return false
	
func find_item(array, item) -> int:
	if not item in array:
		return -1
	for index in len(array):
		if array[index] == item:
			return index
	return -1
	
func array_unique(array: Array) -> Array:
	var unique: Array = []

	for item in array:
		if not unique.has(item):
			unique.append(item)

	return unique
	
	
func get_all_children(in_node, children_acc = []):
	children_acc.push_back(in_node)
	for child in in_node.get_children():
		children_acc = get_all_children(child, children_acc)

	return children_acc
	
func parents_in_group(node, group: String) -> bool:
	var n = node
	while n:
		if n.is_in_group(group):
			return true
		n = n.get_parent()
	return false
	
func parents(node) -> Array[Object]:
	var n = node
	var arr : Array[Object] = []
	while n:
		arr.append(n)
		n = n.get_parent()
	return arr
				
func average_vector3(vectors: Array) -> Vector3:
	var sum = Vector3(0, 0, 0)
	for vec in vectors:
		sum += vec

	var count = vectors.size()
	if count == 0:
		return Vector3(0, 0, 0)  # Handle case with no vectors to avoid division by zero.

	return sum / count
	
func sum_array(array: Array) -> float:
	var sum := 0.0
	for element in array:
		sum += element
	return sum
	
func max_key(dict):
	var _max_key = null
	var max_value = -INF

	for key in dict.keys():
		if dict[key] > max_value:
			max_value = dict[key]
			_max_key = key

	return _max_key
	
func min_key(dict):
	var _max_key = null
	var max_value = INF

	for key in dict.keys():
		if dict[key] < max_value:
			max_value = dict[key]
			_max_key = key

	return _max_key


class CurveMap3D:
	var curve : Curve
	var start : Vector3
	var end : Vector3
	var amplitude : float
	var time : float
	
	func constructor(p_curve : Curve, p_start : Vector3, p_end: Vector3, p_amplitude: float, p_time: float) -> CurveMap3D:
		self.curve = p_curve
		self.start = p_start
		self.end = p_end
		self.amplitude = p_amplitude
		self.time = p_time
		return self
		
	func get_velocity_at(elapsed: float) -> Vector3:
		var small_delta = 0.01
		var t1 = clamp(elapsed / time, 0.0, 1.0)
		var t0 = clamp(t1 - small_delta, 0.0, 1.0)

		var pos1 = start.lerp(end, t1)
		pos1.y += curve.sample(t1) * amplitude

		var pos0 = start.lerp(end, t0)
		pos0.y += curve.sample(t0) * amplitude

		return (pos1 - pos0) / (small_delta * time)
			
	func get_point_at(elapsed: float) -> Vector3:
		var t = clamp(elapsed / time, 0.0, 1.0)

		var pos = start.lerp(end, t)
		var dy = end.y - start.y
		var baseline_y = start.y + dy * t

		var raw = curve.sample(t)
		var start_val = curve.sample(0.0)
		var end_val = curve.sample(1.0)
		var offset = raw - lerp(start_val, end_val, t)

		pos.y = baseline_y + offset * amplitude

		return pos


class CurveMap3DMove:
	var curve_map_3d : CurveMap3D
	var time : float = 0.0
	var node: Node3D
	signal Finished
	var _finished_emitted : bool = false
	
	func constructor(p_curve_map_3d : CurveMap3D, p_node: Node3D) -> CurveMap3DMove:
		self.curve_map_3d = p_curve_map_3d
		self.node = p_node
		return self
		
	func reset() -> void:
		self._finished_emitted = false
		self.time = 0.0
		
	func t() -> float:
		return clamp(time / curve_map_3d.time, 0.0, 1.0)
		
	func get_velocity():
		return self.curve_map_3d.get_velocity_at(self.t())
		
	func update(delta: float) -> bool:
		time += delta
		var _t = self.t()
		
		if _t < 1.0:
			node.global_position = curve_map_3d.get_point_at(_t)
		
		if _t >= 0.8 and not _finished_emitted:
			_finished_emitted = true
			emit_signal("Finished")

		return _t >= 1.0
		
	
