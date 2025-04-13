extends Node
#class_name Serializer

func user(file_path: String) -> String:
	return "user://" + file_path

func write_json(file_path : String, data : Dictionary, as_user=true) -> void:
	var _path = file_path
	if as_user:
		_path = self.user(_path)
	var json_file = FileAccess.open(_path, FileAccess.WRITE)
	json_file.store_line(JSON.stringify(data))

func read_json(file_path : String, as_user=true) -> Dictionary:
	var _path = file_path
	if as_user:
		_path = self.user(_path)
		
	if not FileAccess.file_exists(_path):
		return {}
	var file_data := FileAccess.open(_path, FileAccess.READ)
	if not file_data:
		return {}
	var parsed_data = JSON.parse_string(file_data.get_as_text())
	
	if parsed_data is Dictionary:
		return parsed_data
	return {}
