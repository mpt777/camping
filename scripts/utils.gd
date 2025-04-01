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
	var max_key = null
	var max_value = -INF

	for key in dict.keys():
		if dict[key] > max_value:
			max_value = dict[key]
			max_key = key

	return max_key
	
func min_key(dict):
	var max_key = null
	var max_value = INF

	for key in dict.keys():
		if dict[key] < max_value:
			max_value = dict[key]
			max_key = key

	return max_key
