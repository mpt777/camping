extends CharacterBody3D
class_name Player
		
# Get the gravity from the project settings to be synced with RigidBody nodes.

const FISHING_POLE = preload("res://scenes/items/fishing_pole/fishing_pole.tscn")

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		## Give authority over the player input to the appropriate peer.
		##$PlayerInput.set_multiplayer_authority(id)
		#$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var n_label = $Label3D
@onready var n_mesh = $Mesh
@onready var ui: CanvasLayer = $UI
@onready var n_camera_anchor : CameraAnchor = $CameraAnchor

var player_data : PlayerData
var ui_locked = false

func constructor(m_player_data : PlayerData) -> Player:
	self.player_data = m_player_data
	return self

func constructor_node() -> Player:
	
	self.position = Utils.parents(self).filter(func(x): return x is World)[0].n_player_spawn.global_position
	
	self.player = name.to_int()
	
	Game.SyncPlayers.connect(sync_player)
	Signals.UILock.connect(set_ui_lock)
	if player == multiplayer.get_unique_id():
		$CameraAnchor.n_camera.current = true
		self.ui.visible = true
		
	self.sync_player()
	self.render()
	
	return self
	

	
	#self.position.y += randf() * 1
	#self.position.x += randf() * 10
	#self.position.z += randf() * 10
	
	#$Items.add_child(FISHING_POLE.instantiate())


func sync_player():
	if self.player in Game.players:
		self.player_data = Game.players[self.player]
		self.render()
		Signals.PlayerLoaded.emit(self.player, self.player_data)

func render():
	if self.player_data:
		n_label.text = self.player_data.name
	
func set_ui_lock(lock: bool) -> void:
	self.ui_locked = lock
