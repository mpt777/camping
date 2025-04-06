extends Node3D
class_name FishingPole

const BOBBER = preload("res://scenes/items/bobber/bobber.tscn")
@onready var bobber_anchor := $BobberAnchor
@onready var display_bobber : Bobber = $BobberAnchor/Bobber

var out_bobber : Bobber= null

var is_active := false

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event.is_action_pressed("left_mouse"):
		if self.is_active:
			self.reel()
		else:
			self.cast()
		
func cast() -> void:
	print("cast")
	out_bobber = BOBBER.instantiate()
	out_bobber.set_uuid()
	out_bobber.set_multiplayer_authority(self.get_multiplayer_authority())
	out_bobber.position = self.bobber_anchor.global_position
	out_bobber.freeze = false
	out_bobber.linear_velocity = Vector3.ZERO
	out_bobber.angular_velocity = Vector3.ZERO
	Signals.AddProjectile.emit(out_bobber)
	
	var force = -global_transform.basis.z.normalized() * 5 + Vector3(0, 5, 0)
	out_bobber.apply_central_impulse(force)
	self.is_active = true
	display_bobber.visible = false

	
func reel() -> void:
	out_bobber.queue_free()
	self.is_active = false
	display_bobber.visible = true
