extends Node3D
class_name CameraAnchor

@export var mouse_sensitivity := 0.001
@export var camera_easing := 6.0
@export var look_dir:= Vector2()

@onready var n_spring : SpringArm3D = $SpringArm3D
@onready var n_camera : Camera3D = %Camera
@onready var n_position : Node3D = %SpringPosition

var mouse_captured := true

func _ready():
	pass
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion and \
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and \
		Input.is_mouse_button_pressed(2):
		look_dir = event.relative * 0.001
		self._rotate_camera()
		
	if event.is_action_pressed("wheel_up"):
		n_spring.spring_length -= 1
	if event.is_action_pressed("wheel_down"):
		n_spring.spring_length += 1
	if Input.is_action_just_pressed("exit"):
		self.set_mouse_capture(!self.mouse_captured)

func set_mouse_capture(b : bool):
	self.mouse_captured = b 
	self.set_mouse_mode()
	
func set_mouse_mode():
	if self.mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _rotate_camera(sens_mod: float = 1.0) -> void:
	#camera_anchor.rotation.y -= look_dir.x * 1 * sens_mod
	if mouse_captured && look_dir != Vector2():
		rotation.x = clamp(rotation.x - look_dir.y * 1 * 1, -1.5, 1.5)
		rotation.y -= look_dir.x * 1 * sens_mod

func _physics_process(delta: float) -> void:
	self.n_camera.position = lerp(self.n_camera.position, self.n_position.position, delta * self.camera_easing)
