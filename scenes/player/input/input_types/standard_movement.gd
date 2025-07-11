extends PlayerInput

#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 25

const SPEED = 7
const JUMP_VELOCITY = 10

@export var ACCELERATION := 0.8
@export var FRICTION := 0.5
@export var rotation_speed := 10

@export var jumping := false
@export var direction := Vector2()

var animated_state : Enums.ANIMATION = Enums.ANIMATION.IDLE

func code() -> String:
	return "movement"
	
func _unhandled_input(event: InputEvent) -> void:
	if !is_valid():
		return
		
	if event.is_action_pressed("jump"):
		jumping = true
		
	if event.is_action_pressed("emote"):
		if self.animated_state == Enums.ANIMATION.EMOTE:
			self.animated_state = Enums.ANIMATION.IDLE
		else:
			self.animated_state = Enums.ANIMATION.EMOTE
			body.player_mesh.animate_to(Enums.ANIMATION.EMOTE)


func process(_delta):
	if !is_valid():
		direction = Vector2.ZERO
		return
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	
func physics_process(delta):
	if !is_valid():
		return
		
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta

	if jumping:
		body.velocity.y = JUMP_VELOCITY

	# Reset jump state.
	jumping = false
	
	var local_direction : Vector3 = Vector3(direction.x, 0, direction.y)
	local_direction = local_direction.rotated(Vector3.UP, body.n_camera_anchor.n_camera.global_rotation.y)
	
	var _direction : Vector3 = (body.transform.basis * local_direction).normalized()
	var local_velocity := body.velocity
	if _direction.length() > 0:
		local_velocity = body.velocity.lerp(_direction * SPEED, ACCELERATION)
	else:
		local_velocity = body.velocity.lerp(Vector3.ZERO, FRICTION)
	body.velocity.x = local_velocity.x
	body.velocity.z = local_velocity.z
	
	var pos := body.global_position
	if pos == body.global_position:
		pos = body.velocity.normalized() * 10000
	if pos != Vector3.ZERO && abs(pos.x) > 0.99 && pos != body.global_position:
		var new_transform = body.player_mesh.transform.looking_at(pos, Vector3.UP)
		body.player_mesh.transform = body.player_mesh.transform.interpolate_with(new_transform, rotation_speed * delta) 
	body.player_mesh.rotation.x = 0
	body.player_mesh.rotation.z = 0

	body.move_and_slide()
	
	#print(body.velocity.length() )
	if not body.player_mesh.animation_lock:
		if self.animated_state != Enums.ANIMATION.EMOTE:
			if body.is_on_floor():
				if body.velocity.length() > 5:
					body.player_mesh.animate_to(Enums.ANIMATION.WALK)
				else:
					body.player_mesh.animate_to(Enums.ANIMATION.IDLE)
			else:
				body.player_mesh.animate_to(Enums.ANIMATION.FALLING)
