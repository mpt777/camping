extends CharacterBody3D
class_name Player

const SPEED = 15
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		#$PlayerInput.set_multiplayer_authority(id)
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $PlayerInput
@onready var n_label = $Label3D
var player_data : PlayerData

func constructor(m_player_data : PlayerData) -> Player:
	self.player_data = m_player_data
	print(m_player_data)
	return self

func _ready():
	Game.SyncPlayers.connect(sync_player)
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		$CameraAnchor/Camera3D.current = true
	self.sync_player()
	self.render()
	self.position.y += randf() * 1
	self.position.x += randf() * 10
	self.position.z += randf() * 10
	
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

func _rotate_camera(sens_mod: float = 1.0) -> void:
	#camera_anchor.rotation.y -= look_dir.x * 1 * sens_mod
	if input.mouse_captured && input.look_dir != Vector2():
		$CameraAnchor.rotation.x = clamp($CameraAnchor.rotation.x - input.look_dir.y * 1 * 1, -1.5, 1.5)
		rotation.y -= input.look_dir.x * 1 * sens_mod
	
func _physics_process(delta):
	# Add the gravity.
	if !is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Reset jump state.
	input.jumping = false

	# Handle movement.
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	_rotate_camera()
	move_and_slide()
