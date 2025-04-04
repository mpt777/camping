extends CharacterBody3D
class_name Player

const SPEED = 7
const JUMP_VELOCITY = 4.5

@export var ACCELERATION := 0.8
@export var FRICTION := 0.5
@export var rotation_speed := 10
		
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
@export var jumping := false
@export var direction := Vector2()

var player_data : PlayerData
var ui_locked = false

func constructor(m_player_data : PlayerData) -> Player:
	self.player_data = m_player_data
	return self

func _ready():
	Game.SyncPlayers.connect(sync_player)
	Signals.UILock.connect(set_ui_lock)
	if player == multiplayer.get_unique_id():
		$CameraAnchor.n_camera.current = true
		self.ui.visible = true
		
	self.sync_player()
	self.render()
	
	#self.position.y += randf() * 1
	#self.position.x += randf() * 10
	#self.position.z += randf() * 10
	
func _enter_tree() -> void:
	$".".set_multiplayer_authority(name.to_int())
	$ServerSynchronizer.set_multiplayer_authority(name.to_int())
	self.player = name.to_int()

func sync_player():
	if self.player in Game.players:
		self.player_data = Game.players[self.player]
		self.render()

func render():
	if self.player_data:
		n_label.text = self.player_data.name
	
func set_ui_lock(lock: bool) -> void:
	self.ui_locked = lock
	
@rpc("call_local")
func jump():
	jumping = true
	
func _process(delta):
	if !is_multiplayer_authority():
		return
	if self.ui_locked:
		direction = Vector2.ZERO
		return
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
		
func _physics_process(delta):
	# Add the gravity.
	if !is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Reset jump state.
	jumping = false
	
	var local_direction : Vector3 = Vector3(direction.x, 0, direction.y)
	local_direction = local_direction.rotated(Vector3.UP, $CameraAnchor.n_camera.global_rotation.y)
	
	var direction = (transform.basis * local_direction).normalized()
	var local_velocity := velocity
	if direction.length() > 0:
		local_velocity = velocity.lerp(direction * SPEED, ACCELERATION)
	else:
		local_velocity = velocity.lerp(Vector3.ZERO, FRICTION)
	velocity.x = local_velocity.x
	velocity.z = local_velocity.z
	
	var pos := global_position
	if pos == global_position:
		pos = velocity.normalized() * 10000
	if pos != Vector3.ZERO && abs(pos.x) > 0.99 && pos != global_position:
		var new_transform = n_mesh.transform.looking_at(pos, Vector3.UP)
		n_mesh.transform = n_mesh.transform.interpolate_with(new_transform, rotation_speed * delta) 
	n_mesh.rotation.x = 0
	n_mesh.rotation.z = 0

	move_and_slide()
