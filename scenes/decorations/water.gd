#extends Area3D
#class_name Water
#
#var material: ShaderMaterial
#var noise: Image
#
#var noise_scale: float
#var wave_speed: float
#var height_scale: float
#
#var time: float
#@onready var mesh3D = $water
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#material = mesh3D.material_override
	#noise = mesh3D.material_override.get_shader_parameter("wave").noise.get_seamless_image(512, 512)
	#noise_scale = mesh3D.material_override.get_shader_parameter("noise_scale")
	#wave_speed = mesh3D.material_override.get_shader_parameter("wave_speed")
	#height_scale = mesh3D.material_override.get_shader_parameter("height_scale")
#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#time += delta
	#material.set_shader_parameter("wave_time", time)
#
#func get_height(world_position: Vector3) -> float:
	#var uv_x = wrapf(world_position.x / noise_scale + time * wave_speed, 0, 1)
	#var uv_y = wrapf(world_position.z / noise_scale + time * wave_speed, 0, 1)
#
	#var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	#return global_position.y + noise.get_pixelv(pixel_pos).r * height_scale;

extends Area3D
class_name Water

var material: ShaderMaterial

var displacement_texture : Image  # Change this to ImageTexture
var wind_intensity : float
var wind_direction : Vector3

var displacement_strength : float
var displacement_scroll_speed : float
var displacement_scroll_offset : Vector2

var displacement_scale_offset : float
var displacement_scale : Vector2
#var displacement_scale : float

var time : float 

@onready var mesh3D = $water

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh3D.mesh.surface_get_material(0)
	displacement_strength = mesh3D.material_override.get_shader_parameter("displacement_strength")
	displacement_scroll_speed = mesh3D.material_override.get_shader_parameter("displacement_scroll_speed")
	displacement_scroll_offset = mesh3D.material_override.get_shader_parameter("displacement_scroll_offset")
	
	displacement_scale_offset = mesh3D.material_override.get_shader_parameter("displacement_scale_offset")
	displacement_scale = mesh3D.material_override.get_shader_parameter("displacement_scale")
	
	# Assuming displacement_texture is an ImageTexture
	displacement_texture = mesh3D.material_override.get_shader_parameter("displacement_texture").noise.get_seamless_image(512, 512)
	
	wind_intensity = 0.1
	wind_direction = Vector3(1,0,0)
	
func fma(a, b, c):
	return a * b + c

func _process(delta):
	time += delta
	mesh3D.material_override.set_shader_parameter("displacement_time", time)

func get_height(world_position: Vector3) -> float:
	# Calculate the time offset based on wind intensity and scroll speed
	var time_offset = time * displacement_scroll_speed * fma(wind_intensity, 0.7, 0.3)
	
	var wind_xz = Vector2(wind_direction.x, wind_direction.z)
	var world_xz = Vector2(world_position.x, world_position.z)
	
	var uv1 = fma(world_xz, displacement_scale, time_offset * -wind_xz)
	var pixel_pos1 = Vector2(wrapf(uv1.x, 0, 1) * displacement_texture.get_width(), wrapf(uv1.y, 0, 1) * displacement_texture.get_height())
	var displace1 = displacement_texture.get_pixelv(pixel_pos1).r

	var uv2 = fma(world_xz, displacement_scale * displacement_scale_offset, time_offset * (-wind_xz + displacement_scroll_offset))
	var pixel_pos2 = Vector2(wrapf(uv2.x, 0, 1) * displacement_texture.get_width(), wrapf(uv2.y, 0, 1) * displacement_texture.get_height())
	var displace2 = displacement_texture.get_pixelv(pixel_pos2).r
	
	# Mix the displacements with a factor of 0.4
	var displacement_mixed = lerp(displace1, displace2, 0.4)

	# Apply the displacement strength
	var offset = fma(displacement_mixed, 2.0, -1.0) * displacement_strength
	return global_position.y + offset;

#func get_height(world_position: Vector3) -> float:
	#var uv_x = wrapf(world_position.x + time * displacement_scroll_speed, 0, 1)
	#var uv_y = wrapf(world_position.z + time * displacement_scroll_speed, 0, 1)
#
	#var pixel_pos = Vector2(uv_x * displacement_texture.get_width(), uv_y * displacement_texture.get_height())
	#return global_position.y + displacement_texture.get_pixelv(pixel_pos).r * displacement_strength;
