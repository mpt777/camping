extends Item
class_name FishingPole

const BOBBER = preload("res://scenes/items/tools/bobber/bobber.tscn")
const MG_FISHING = preload("res://scenes/minigames/fishing/mg_fishing.tscn")
const CAST_RATE := 10
const CATCH_RANGE : Array[int] = [2, 10]


@onready var bobber_anchor := $BobberAnchor
@onready var cast_anchor := $BobberAnchor/CastAnchor
@onready var bobber : Bobber = $BobberAnchor/Bobber
@onready var n_timer : Timer = $Timer

@onready var n_rope : Rope = $Draw3D
@export var bobber_position : Vector3

var is_held = false
var is_held_old = false

enum states {
	IDLE,
	TARGET,
	CAST,
	MINIGAME
}
@export var state = states.IDLE
var player : Player

func constructor(m_player : Player) -> FishingPole:
	self.player = m_player
	self.active = true
	return self

func _ready() -> void:
	self.bobber.EnteredWater.connect(bobber_entered_water)
	self.player = Utils.parents(self).filter(func(x): return x is Player)[0]
	self.active = true

func _process(delta: float) -> void:
	
	if is_multiplayer_authority():
		self.bobber_position = self.bobber.global_position
		
	self.draw_line()
	
	if !is_multiplayer_authority():
		return
	if !self.active:
		return
		
	self.cast_anchor.global_rotation.x = 0
	
	self.advance_state(delta)
	self.is_held_old = self.is_held
	
func draw_line() -> void:
	self.n_rope.reset()
	if self.bobber_position == Vector3.ZERO:
		return
	if (self.state in [states.CAST, states.MINIGAME]) or (!is_multiplayer_authority()):
		self.n_rope.add_point(self.bobber_anchor.global_position)
		self.n_rope.add_point(self.bobber_position)
		self.n_rope.add_point(self.bobber_position)
		self.n_rope.draw_line()
	
func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if !self.active:
		return
	if event.is_action_released("left_mouse"):
		self.is_held = false
	if event.is_action_pressed("left_mouse"):
		self.is_held = true
		
func advance_state(delta : float) -> void:
	if self.is_held:
		self.target(delta)
		self.reel(delta)
			#
	if self.is_held == self.is_held_old:
		return
		
	if self.is_held:
		if self.state == states.IDLE:
			self.state = states.TARGET
			return
			
	if not self.is_held:
		if self.state == states.TARGET:
			self.state = states.CAST
			self.cast()
		
func target(delta) -> void:
	if self.state == states.TARGET:
		self.cast_anchor.visible = true
		self.cast_anchor.position.z -=  (delta * self.CAST_RATE)
		self.cast_anchor.global_position.y = self.bobber_anchor.global_position.y
		

func calculate_arc_velocity(start: Vector3, end: Vector3, time: float) -> Vector3:
	var displacement = end - start

	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Default 9.8
	var horizontal_displacement = Vector3(displacement.x, 0, displacement.z)
	var horizontal_distance = horizontal_displacement.length()

	# Horizontal velocity
	var vxz = horizontal_displacement.normalized() * (horizontal_distance / time)

	# Vertical velocity
	var vy = (displacement.y + 0.5 * gravity * time * time) / time

	return Vector3(vxz.x, vy, vxz.z)
	
func cast() -> void:
	self.bobber.position = Vector3(0,0,0)
	self.bobber.top_level = true
	self.bobber.global_position = self.bobber.global_position
	self.bobber.freeze = false
	# Arc!
	self.bobber.linear_velocity = calculate_arc_velocity(
		self.bobber_anchor.global_position, 
		self.cast_anchor.global_position,
		1
	)
	self.bobber.angular_velocity = Vector3.ZERO
	
	self.cast_anchor.visible = false
	self.cast_anchor.position = Vector3.ZERO
	#end arc
	
	
func reel(_delta) -> void:
	if self.state != states.CAST:
		return
	self.bobber.apply_central_force(self.bobber.global_position.direction_to(global_position) * self.CAST_RATE)
	if (self.bobber.global_position.distance_squared_to(global_position) < 5):
		self.state = states.IDLE
		self.end()

	
func end() -> void:
	self.state = states.IDLE
	self.bobber.freeze = true
	self.bobber.top_level = false
	self.bobber.position = Vector3(0,0,0)

	self.n_timer.stop()
	
func bobber_entered_water():
	var _time = randf_range(self.CATCH_RANGE[0], self.CATCH_RANGE[1])
	self.n_timer.start()

func _on_timer_timeout() -> void:
	if self.state != states.CAST:
		return
	print("Bite!")
	self.state = states.MINIGAME
	var mg = MG_FISHING.instantiate()
	self.player.enter_minigame(mg)
	mg.Exited.connect(func():
		self.end()
	)
