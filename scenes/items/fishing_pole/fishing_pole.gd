extends Item
class_name FishingPole

const BOBBER = preload("res://scenes/items/bobber/bobber.tscn")
const MG_FISHING = preload("res://scenes/minigames/fishing/mg_fishing.tscn")

@onready var bobber_anchor := $BobberAnchor
@onready var display_bobber : Bobber = $BobberAnchor/Bobber
@onready var n_timer : Timer = $Timer
var out_bobber : Bobber= null

var target_length = 0

enum states {
	IDLE,
	TARGET,
	CAST,
	MINIGAME
}
var state = states.IDLE
var player : Player

func constructor(m_player : Player) -> FishingPole:
	self.player = m_player
	self.active = true
	return self

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if !self.active:
		return
	self.target(delta)
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if !self.active:
		return
	if self.state == states.TARGET:
		if event.is_action_released("left_mouse"):
			self.advance_state()
	if event.is_action_pressed("left_mouse"):
		self.advance_state()

		
func advance_state():
	if self.state == states.IDLE:
		self.state = states.TARGET
		return
		
	if self.state == states.TARGET:
		self.state = states.CAST
		self.cast()
		return
		
	if self.state == states.CAST:
		self.state = states.IDLE
		self.reel()
		return
		
func target(delta) -> void:
	if self.state == states.TARGET:
		self.target_length += (delta * 10)
		self.display_bobber.position.z -=  (delta * 10)
		
func cast() -> void:
	out_bobber = BOBBER.instantiate()
	#out_bobber.set_uuid()
	out_bobber.set_multiplayer_authority(self.get_multiplayer_authority())
	out_bobber.position = self.bobber_anchor.global_position
	out_bobber.freeze = false
	out_bobber.linear_velocity = Vector3.ZERO
	out_bobber.angular_velocity = Vector3.ZERO
	Signals.AddProjectile.emit(out_bobber)
	
	#var force = -global_transform.basis.z.normalized() * 5 + Vector3(0, 5, 0)
	#out_bobber.apply_central_impulse(force)
	#out_bobber.position = self.global_position - Vector3(0, 0, self.target_length)
	out_bobber.position = display_bobber.global_position
	self.target_length = 0
	display_bobber.visible = false
	display_bobber.position = Vector3.ZERO
	
	
	out_bobber.EnteredWater.connect(bobber_entered_water)
	
func reel() -> void:
	out_bobber.queue_free()
	self.state = states.IDLE
	display_bobber.visible = true
	self.n_timer.stop()
	
func bobber_entered_water():
	self.n_timer.start(3)

func _on_timer_timeout() -> void:
	print("Bite!")
	self.state = states.MINIGAME
	var mg = MG_FISHING.instantiate()
	self.player.enter_minigame(mg)
	mg.Exited.connect(func():
		self.reel()
	)
