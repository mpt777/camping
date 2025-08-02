extends WorldEnvironment

@export_range(0.0, 24.0, 0.1)
var time: float = 12.0:
	set(value):
		time = value
		render()

@export var day_length: float = (0.5 * 60) # full day cycle in seconds
@export var astro : DirectionalLight3D 

@export var sunrise_start := 0.20
@export var day_start     := 0.30
@export var sunset_start  := 0.70
@export var night_start   := 0.80

const NIGHT_ANGLE   = 90.0
const SUNRISE_ANGLE = 0.0
const DAY_ANGLE     = -90.0
const SUNSET_ANGLE  = -180.0
const NIGHT2_ANGLE  = -270.0 # loops back to -90


@onready var shader: ShaderMaterial = null

func _ready() -> void:
	shader = environment.sky.sky_material
	render()

func _physics_process(delta: float) -> void:
	time += (24.0 / day_length) * delta
	time = fmod(time, 24.0) # Wrap around after 24 hours
	render()
	
	
func remap_value(t: float, a: float, b: float) -> float:
	return clamp((t - a) / (b - a), 0.0, 1.0)

func rotate_astro(t: float) -> void:
	if not astro:
		return

	var angle := 0.0
	
	if t < sunrise_start:
		angle = NIGHT_ANGLE
	elif t < day_start:
		var f = remap_value(t, sunrise_start, day_start)
		angle = lerp(NIGHT_ANGLE, SUNRISE_ANGLE, f)
	elif t < sunset_start:
		var f = remap_value(t, day_start, sunset_start)
		angle = lerp(SUNRISE_ANGLE, DAY_ANGLE, f)
	elif t < night_start:
		var f = remap_value(t, sunset_start, night_start)
		angle = lerp(DAY_ANGLE, SUNSET_ANGLE, f)
	else:
		var f = remap_value(t, night_start, 1.0)
		angle = lerp(SUNSET_ANGLE, NIGHT2_ANGLE, f)

	astro.rotation_degrees.x = angle

func render():
	var normalized_time = fmod(time / 24.0, 1.0)
	rotate_astro(normalized_time)
	if shader:
		shader.set_shader_parameter("time_of_day", normalized_time)
