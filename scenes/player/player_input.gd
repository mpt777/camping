extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := Vector2()
@export var look_dir:= Vector2()
var mouse_captured := true
@export var camera_anchor : Node3D
@export var body : CharacterBody3D

func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true
	
func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		#_rotate_camera()
	
	if Input.is_action_just_pressed("exit"):
		self.set_mouse_capture(!self.mouse_captured)

func _process(delta):
	look_dir = Vector2()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
		
	
func set_mouse_capture(b : bool):
	self.mouse_captured = b 
	self.set_mouse_mode()
	
func set_mouse_mode():
	if self.mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
