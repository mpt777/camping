extends Node3D
class_name FishingPole

const BOBBER = preload("res://scenes/items/bobber/bobber.tscn")
@onready var bobber_anchor := $BobberAnchor
@onready var display_bobber : Bobber = $BobberAnchor/Bobber
@onready var n_timer : Timer = $Timer
var out_bobber : Bobber= null

var is_active := false
var player : Player

func constructor(m_player : Player) -> FishingPole:
	self.player = m_player
	return self

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event.is_action_pressed("left_mouse"):
		if self.is_active:
			self.reel()
		else:
			self.cast()
		
func cast() -> void:
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
	
	out_bobber.EnteredWater.connect(bobber_entered_water)
	
func reel() -> void:
	out_bobber.queue_free()
	self.is_active = false
	display_bobber.visible = true
	self.n_timer.stop()
	
func bobber_entered_water():
	self.n_timer.start(3)

func _on_timer_timeout() -> void:
	print("Caught!")
