@tool
extends WorldEnvironment

@export_range(0.0, 24.0, 0.1)
var time: float = 12.0:
	set(value):
		time = value
		render()
		
@export
var is_paused: bool = false:
	set(value):
		is_paused = value

@export var day_length: float = (0.5 * 60) # full day cycle in seconds
@export var astro : DirectionalLight3D 
@export var moon : DirectionalLight3D 

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
	shader = environment.sky.sky_material
	if shader:
		shader.set_shader_parameter("sunrise_start", sunrise_start)
		shader.set_shader_parameter("day_start", day_start)
		shader.set_shader_parameter("sunset_start", sunset_start)
		shader.set_shader_parameter("night_start", night_start)
	render()
	

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	time += (24.0 / day_length) * delta
	time = fmod(time, 24.0) # Wrap around after 24 hours
	render()
	
	
func remap_value(t: float, a: float, b: float) -> float:
	return clamp((t - a) / (b - a), 0.0, 1.0)
	
func is_day() -> bool:
	var sun_dir = astro.global_transform.basis.z.normalized()
	var up = Vector3.UP
	return sun_dir.dot(up) > 0.0

func rotate_astro(t: float) -> void:
	if not astro:
		return
	if not moon:
		return

	#var angle := 0.0
	
	#if t < sunrise_start:
		#angle = NIGHT_ANGLE
	#elif t < day_start:
		#var f = remap_value(t, sunrise_start, day_start)
		#angle = lerp(NIGHT_ANGLE, SUNRISE_ANGLE, f)
	#elif t < sunset_start:
		#var f = remap_value(t, day_start, sunset_start)
		#angle = lerp(SUNRISE_ANGLE, DAY_ANGLE, f)
	#elif t < night_start:
		#var f = remap_value(t, sunset_start, night_start)
		#angle = lerp(DAY_ANGLE, SUNSET_ANGLE, f)
	#else:
		#var f = remap_value(t, night_start, 1.0)
		#angle = lerp(SUNSET_ANGLE, NIGHT2_ANGLE, f)

	#astro.rotation_degrees.x = angle
	#astro.rotation_degrees.x = -lerp(-90, 270, t)
	
	var sun_angle = lerp(-90.0, 270.0, t)
	astro.rotation_degrees.x = -sun_angle
	moon.rotation_degrees.x = -astro.rotation_degrees.x
	
	var _is_day : bool = self.is_day()
	astro.visible=_is_day
	moon.visible = not _is_day

	## Optional: fade light energy smoothly
	#var sun_weight = clamp(remap_value(t, sunrise_start, sunset_start), 0.0, 1.0)
	#var moon_weight = 1.0 - sun_weight
#
	#astro.light_energy = sun_weight
	#moon.light_energy = moon_weight
	

func render():
	var normalized_time = fmod(time / 24.0, 1.0)
	rotate_astro(normalized_time)
	if shader:
		shader.set_shader_parameter("time_of_day", normalized_time)
		shader.set_shader_parameter("SUN_DIRECTION", astro.global_transform.basis.z.normalized())
