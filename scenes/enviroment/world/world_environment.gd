@tool
extends WorldEnvironment

@export_range(0.0, 24.0, 0.1)
var time: float = 12.0:
	set(value):
		time = value
		if Engine.is_editor_hint():
			render()
		
var old_target_time: float = 12.0
@export var target_time: float = 12.0
	#set(value):
		#target_time = value
		#if not multiplayer.is_server():
			#var diff = abs(time - target_time)
			#if diff < snap_threshold:
				#time = lerp_angle(time, target_time, 1 * delta)
			#else:
				#time = target_time
			
@export var sync_speed: float = 0.5 # how fast to blend toward synced time
@export var snap_threshold: float = 0.5 # in hours, e.g. 0.5 = 30 minutes
		
@export
var is_paused: bool = false:
	set(value):
		is_paused = value

@export var day_length: float = (0.5 * 60) # full day cycle in seconds
@export var astro : DirectionalLight3D 
@export var moon : DirectionalLight3D 

@export var astro_power : float = 0.25
@export var moon_power : float = 0.1

@export var sunrise_start := 0.10
@export var day_start     := 0.30
@export var sunset_start  := 0.60
@export var night_start   := 0.80

const NIGHT_ANGLE   = 90.0
const SUNRISE_ANGLE = 15.0
const DAY_ANGLE     = -15.0
const SUNSET_ANGLE  = -165.0
const NIGHT2_ANGLE  = -270.0 # loops back to -90


@onready var shader: ShaderMaterial = null

func _ready() -> void:
	if self.multiplayer.has_multiplayer_peer() and self.multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_player_connected)
	
	shader = environment.sky.sky_material
	if shader:
		shader.set_shader_parameter("sunrise_start", sunrise_start)
		shader.set_shader_parameter("day_start", day_start)
		shader.set_shader_parameter("sunset_start", sunset_start)
		shader.set_shader_parameter("night_start", night_start)
	render()
	
	
func _on_player_connected(id : int):
	update_target_time.rpc_id(id, self.target_time)
	
	
@rpc("authority", "call_local", "unreliable")
func update_target_time(p_target_time : float):
	target_time = p_target_time
	
func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	var local_increment = (24.0 / day_length) * delta
	
	#Server Time
	var is_server = multiplayer.is_server()
	if is_server and target_time:
		target_time = fmod(target_time + local_increment, 24.0)
	
	if not is_server and old_target_time != target_time:
		time = target_time
		old_target_time = target_time
	else:
		time = fmod(time + local_increment, 24.0)
		#self.update_target_time.rpc(target_time)
		
	
		# otherwise smooth drift
	#time = lerp(time, target_time, 1 * delta)
	#time = target_time
		
	#time += (24.0 / day_length) * delta
	#time = fmod(time, 24.0) # Wrap around after 24 hours
	render()
	
	
func remap_value(t: float, a: float, b: float) -> float:
	return clamp((t - a) / (b - a), 0.0, 1.0)
	
func is_day() -> bool:
	var sun_dir = astro.global_transform.basis.z.normalized()
	var up = Vector3.UP
	return sun_dir.dot(up) > 0.0

func rotate_astro(t: float) -> void:
	if not astro or not moon:
		return

	
	var sun_angle = lerp(-90.0, 270.0, t)
	astro.rotation_degrees.x = -sun_angle
	moon.rotation_degrees.x = -sun_angle + 180

	# gradients
	
	var sun_dot = astro.global_transform.basis.z.normalized().dot(Vector3.UP)
	var moon_dot = moon.global_transform.basis.z.normalized().dot(Vector3.UP)

	var sun_weight = clamp(sun_dot, 0.0, astro_power)
	var moon_weight = clamp(moon_dot, 0.0, moon_power)

	astro.light_energy = sun_weight
	moon.light_energy = moon_weight

	astro.visible = sun_weight > 0.01
	moon.visible = moon_weight > 0.01
	

func render():
	var normalized_time = fmod(time / 24.0, 1.0)
	rotate_astro(normalized_time)
	if shader and astro:
		shader.set_shader_parameter("time_of_day", normalized_time)
		shader.set_shader_parameter("SUN_DIRECTION", astro.global_transform.basis.z.normalized())
