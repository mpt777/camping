extends Item
class_name FishingPole

const BOBBER = preload("res://scenes/items/tools/bobber/bobber.tscn")
const MG_FISHING = preload("res://scenes/minigames/fishing/mg_fishing.tscn")
const CAST_RATE := 10
const CATCH_RANGE : Array[int] = [2, 10]

@onready var rotation_fixer := $RotationFixer
@onready var bobber_anchor := $RotationFixer/BobberAnchor
@onready var cast_anchor := $RotationFixer/BobberAnchor/CastAnchor
@onready var bobber : Bobber = $RotationFixer/BobberAnchor/Bobber
@onready var n_timer : Timer = $Timer

@onready var n_rope : Rope = $RotationFixer/Draw3D
@onready var n_pole_rope : Rope = $RotationFixer/Draw3D2

@export var cast_curve : Curve
var cast_curve_driver : Utils.CurveMap3DMove
@export var line_curve : Curve

var bobber_distance : float = 0

var is_held = false
var is_held_old = false

@export var state = states.IDLE
var player : Player


enum states {
	IDLE,
	TARGET,
	CAST,
	REEL,
	MINIGAME,
	CATCH
}

func draw_reel_straight(fp : FishingPole):
	fp.n_rope.add_point(fp.bobber_anchor.global_position)
	fp.n_rope.add_point(fp.bobber.global_position)
	fp.n_rope.add_point(fp.bobber.global_position)
	fp.n_rope.draw_line()

func draw_reel_curved(fp : FishingPole):
	var points = 20
	var curve_map = Utils.CurveMap3D.new().constructor(
		fp.line_curve, 
		fp.bobber_anchor.global_position,
		fp.bobber.global_position,
		1, points
	)
	for i in range(points + 1):
		fp.n_rope.add_point(curve_map.get_point_at(i))
	fp.n_rope.draw_line()


func constructor(m_player : Player) -> FishingPole:
	self.player = m_player
	self.active = true
	return self

func _ready() -> void:
	self.n_pole_rope.draw_line()
	self.player = Utils.parents(self).filter(func(x): return x is Player)[0]
	self.active = true
	self.ready.connect(on_ready)
	
func on_ready() -> void:
	var auth = Utils.parents(self).filter(func (x): return x is Player)[0].player
	print("Parent Tree", auth)
	self.set_multiplayer_authority(auth)
	
	if self.is_multiplayer_authority():
		self.bobber.EnteredWater.connect(bobber_entered_water)
		self.bobber.HitWorld.connect(bobber_hit_world)
		
	#self.bobber.set_multiplayer_authority(auth)

func is_valid() -> bool:
	if !is_multiplayer_authority():
		return false
	if !self.active:
		return false
	return true
	
func _unhandled_input(event: InputEvent) -> void:
	if !self.is_valid():
		return 
	if event.is_action_released("left_mouse"):
		self.is_held = false
	if event.is_action_pressed("left_mouse"):
		self.is_held = true
		
func draw_line() -> void:
	self.n_rope.reset()
	if self.state in [states.MINIGAME, states.REEL]:
		draw_reel_straight(self)
	if (self.state in [states.CAST, states.CATCH]):
		draw_reel_curved(self)

func update_from_state():
	if self.state in [states.IDLE, states.TARGET]:
		self.bobber.top_level = false
	else:
		self.bobber.top_level = true

func _physics_process(delta: float) -> void:
	if (!is_multiplayer_authority()):
		self.update_from_state()
		
	self.animate()
	self.draw_line()
	
	if !self.is_valid():
		return 
		
	if self.cast_curve_driver:
		self.cast_curve_driver.update(delta)
	self.cast_anchor.global_rotation.x = 0
	
	self.advance_state(delta)
	self.is_held_old = self.is_held
	
func animate() -> void:
	self.n_rope.visible = true
	if self.state == states.IDLE:
		self.n_rope.visible = false
		
	if self.state == states.CATCH:
		self.player.player_mesh.animate_to(Enums.ANIMATION.CAST_START, 0.5)
	
	if self.state == states.MINIGAME:
		self.player.player_mesh.animate_to(Enums.ANIMATION.CAST_START, 0.4)
		
	if self.state == states.REEL:
		self.player.player_mesh.animate_to(Enums.ANIMATION.CAST_START, 0.2)
		
func advance_state(delta : float) -> void:
	if self.is_held:
		if self.state == states.CAST:
			self.state = states.REEL
	else:
		if self.state == states.REEL:
			self.state = states.CAST
			
	self.target(delta)
	self.reel(delta)
			
	if self.is_held == self.is_held_old:
		return
		
	if self.is_held:
		if self.state == states.IDLE or not self.state:
			self.state = states.TARGET
			return
			
	if not self.is_held:
		if self.state == states.TARGET:
			self.state = states.CAST
			self.cast()
		
func target(delta) -> void:
	if self.state != states.TARGET:
		return
	self.player.animated_state = Enums.ANIMATION.EMOTE
	self.player.player_mesh.animate_to(Enums.ANIMATION.CAST_START, 0.8)
	self.cast_anchor.visible = true

	var forward = -self.player.player_mesh.global_basis.z.normalized()
	self.cast_anchor.global_position = self.player.global_position + forward * bobber_distance

	self.bobber_distance += delta * self.CAST_RATE
		
func cast() -> void:
	self.bobber.top_level = true
	self.bobber.global_position = self.bobber.global_position
	self.player.animated_state = Enums.ANIMATION.IDLE
	self.bobber.freeze = false
	self.bobber.angular_velocity = Vector3.ZERO
	
	# Arc!
	self.bobber.linear_velocity = calculate_arc_velocity_with_peak(
		self.bobber_anchor.global_position, 
		self.cast_anchor.global_position,
		self.bobber.global_position.y + 2
	)

	self.cast_anchor.visible = false
	self.cast_anchor.position = Vector3.ZERO
	
func reel(_delta) -> void:
	if self.state != states.REEL:
		return
	self.draw_line()
		
	self.player.player_mesh.animate_to(Enums.ANIMATION.CAST_START, 0.3)
	self.bobber.apply_central_force(self.bobber.global_position.direction_to(global_position) * self.CAST_RATE)
	
	var delta : Vector3 = self.bobber.global_position - global_position
	var distance_squared_xz : float = delta.x * delta.x + delta.z * delta.z

	if distance_squared_xz < 10:
		self.state = states.IDLE
		self.end()
	
func end() -> void:
	self.state = states.IDLE
	self.bobber_distance = 0.0

	self.bobber.top_level = false
	self.bobber.position = Vector3.ZERO
	self.bobber.linear_velocity = Vector3.ZERO
	self.bobber.angular_velocity = Vector3.ZERO
	self.bobber.freeze = true
	
	self.player.animated_state = Enums.ANIMATION.IDLE
	self.n_timer.stop()
	
func to_physics() -> void:
	if self.cast_curve_driver:
		bobber.linear_velocity = self.cast_curve_driver.get_velocity()
	self.cast_curve_driver = null
	self.bobber.freeze = false

func bobber_entered_water() -> void:
	self.to_physics()
	var _time = randf_range(self.CATCH_RANGE[0], self.CATCH_RANGE[1])
	self.bobber.linear_velocity.x = 0
	self.bobber.linear_velocity.z = 0
	self.n_timer.start()
	
func bobber_hit_world() -> void:
	self.to_physics()
	self.n_timer.stop()
	self.end()
	
func catch(fish : FishData) -> void:
	self.state = states.CATCH
	self.player.animated_state = Enums.ANIMATION.IDLE
	
	self.bobber.freeze = true 
	self.cast_curve_driver = Utils.CurveMap3DMove.new().constructor(
		Utils.CurveMap3D.new().constructor(
			self.cast_curve,
			self.bobber.global_position,
			self.player.global_position + Vector3(0,2,0),
			2.0,
			0.8
		),
		self.bobber
	)
	self.bobber.add_fish(fish)
	self.bobber.angular_velocity = Vector3.ZERO
	self.cast_curve_driver.Finished.connect(func():
		self.to_physics()
		self.player.add_item_to_inventory(fish)
		self.bobber.remove_fish()
		self.end()
	)
	
func _on_timer_timeout() -> void:
	if !is_multiplayer_authority():
		return
	if self.state != states.CAST: 
		return
	if !self.bobber.water:
		return
	print("Bite!")
	self.state = states.MINIGAME
	var mg = MG_FISHING.instantiate()
	self.player.enter_minigame(mg)
	mg.Exited.connect(func():
		if mg.success:
			self.catch(mg.current_fish)
		else:
			self.end()
	)
	
#####################################
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
	
func calculate_arc_velocity_with_peak(start: Vector3, end: Vector3, peak_height: float) -> Vector3:
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # e.g. 9.8
	#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # e.g. 9.8

	if peak_height <= start.y or peak_height <= end.y:
		push_error("peak_height must be higher than both start.y and end.y")
		return Vector3.ZERO

	var displacement = end - start
	var horizontal_displacement = Vector3(displacement.x, 0, displacement.z)
	var horizontal_distance = horizontal_displacement.length()

	# --- Vertical motion ---
	var ascent_height = peak_height - start.y
	var descent_height = peak_height - end.y

	var t_up = sqrt(2 * ascent_height / gravity)
	var t_down = sqrt(2 * descent_height / gravity)
	var total_time = t_up + t_down

	# Initial vertical velocity to reach peak
	var vy = gravity * t_up

	# Horizontal velocity
	var vxz = horizontal_displacement.normalized() * (horizontal_distance / total_time)

	return Vector3(vxz.x, vy, vxz.z)
	
