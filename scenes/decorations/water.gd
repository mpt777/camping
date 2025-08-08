extends Area3D
class_name Water

var material: ShaderMaterial
var displacement_texture: Image

var wind_intensity: float
var wind_direction: Vector3

var displacement_strength: float
var displacement_scroll_speed: float
var displacement_scroll_offset: Vector2

var displacement_scale_offset: float
var displacement_scale: Vector2

var time: float = 0.0

var tex_width: int
var tex_height: int

var noise: Image

var noise_scale: float
var wave_speed: float
var height_scale: float

@onready var mesh3D = $water

func _ready():
	#material = mesh3D.mesh.surface_get_material(0)
	material = mesh3D.material_override
	#displacement_strength = mesh3D.material_override.get_shader_parameter("displacement_strength")
	#displacement_scroll_speed = mesh3D.material_override.get_shader_parameter("displacement_scroll_speed")
	#displacement_scroll_offset = mesh3D.material_override.get_shader_parameter("displacement_scroll_offset")
	#displacement_scale_offset = mesh3D.material_override.get_shader_parameter("displacement_scale_offset")
	#displacement_scale = mesh3D.material_override.get_shader_parameter("displacement_scale")
	#
	#displacement_texture = mesh3D.material_override.get_shader_parameter("displacement_texture").get_image()
	#tex_width = displacement_texture.get_width()
	#tex_height = displacement_texture.get_height()
	#
	#wind_intensity = 1.0
	#wind_direction = Vector3(1, 0, 0)
	
	
	noise = material.get_shader_parameter("wave").noise.get_seamless_image(512, 512)
	noise_scale = material.get_shader_parameter("noise_scale")
	wave_speed = material.get_shader_parameter("wave_speed")
	height_scale = material.get_shader_parameter("height_scale")
	

func fma(a, b, c):
	return a * b + c

func _process(delta):
	time += delta
	mesh3D.material_override.set_shader_parameter("displacement_time", time)

#func get_height(world_position: Vector3) -> float:
	#var time_offset = time * displacement_scroll_speed * (wind_intensity * 0.7 + 0.3)
	#var wind_xz = Vector2(wind_direction.x, wind_direction.z)
	#var world_xz = Vector2(world_position.x, world_position.z)
#
	#var uv1 = world_xz * displacement_scale + time_offset * (-wind_xz)
	#var uv2 = world_xz * displacement_scale * displacement_scale_offset + time_offset * (-wind_xz + displacement_scroll_offset)
#
	#uv1.x = fposmod(uv1.x, 1.0)
	#uv1.y = fposmod(uv1.y, 1.0)
	#uv2.x = fposmod(uv2.x, 1.0)
	#uv2.y = fposmod(uv2.y, 1.0)
#
	#var pixel_pos1 = Vector2i(int(floor(uv1.x * tex_width)), int(floor(uv1.y * tex_height)))
	#var pixel_pos2 = Vector2i(int(floor(uv2.x * tex_width)), int(floor(uv2.y * tex_height)))
#
	#var displace1 = displacement_texture.get_pixelv(pixel_pos1).r
	#var displace2 = displacement_texture.get_pixelv(pixel_pos2).r
#
	#var displacement_mixed = lerp(displace1, displace2, 0.4)
#
	#var offset = (displacement_mixed * 2.0 - 1.0) * displacement_strength
#
	#return global_position.y + offset
	
func get_height(world_position: Vector3) -> float:
	var uv_x = wrapf(world_position.x / noise_scale + time * wave_speed, 0, 1)
	var uv_y = wrapf(world_position.z / noise_scale + time * wave_speed, 0, 1)

	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	return global_position.y + noise.get_pixelv(pixel_pos).r * height_scale;
