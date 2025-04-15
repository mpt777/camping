extends MultiplayerSpawner

func _ready():
	self.spawn_function = spawn_player
	
func spawn_player(data) -> Node3D:
	print(data)	
	return data
