extends Node3D
class_name CameraAnchor

@export var mouse_sensitivity := 0.001
@export var camera_easing := 6.0
@export var min_distance := 0
@export var max_distance := 6.0

var look_dir:= Vector2()

@onready var n_spring : SpringArm3D = $SpringArm3D
@onready var n_camera : Camera3D = %Camera
@onready var n_position : Node3D = %SpringPosition


func _ready():
	pass
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("right_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_released("right_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look_dir = event.relative * 0.001
		self._rotate_camera()
		
	if event.is_action_pressed("wheel_up"):
		n_spring.spring_length = max(n_spring.spring_length - 1, self.min_distance)
	if event.is_action_pressed("wheel_down"):
		n_spring.spring_length = min(n_spring.spring_length + 1, self.max_distance)
	#if Input.is_action_just_pressed("exit"):
		#self.set_mouse_capture(!self.mouse_captured)
		
func _rotate_camera(sens_mod: float = 1.0) -> void:
	#camera_anchor.rotation.y -= look_dir.x * 1 * sens_mod
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && look_dir != Vector2():
		rotation.x = clamp(rotation.x - look_dir.y * 1 * 1, -1.5, 1.5)
		rotation.y -= look_dir.x * 1 * sens_mod

func _physics_process(delta: float) -> void:
	self.n_camera.position = lerp(self.n_camera.position, self.n_position.position, delta * self.camera_easing)
