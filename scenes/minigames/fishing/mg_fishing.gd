extends Minigame
class_name MGFishing

const MASHER = preload("res://scenes/minigames/fishing/masher/masher.tscn")

@onready var n_good : ProgressBar = %BarGood
@onready var n_bad : ProgressBar = %BarBad
@onready var n_mashers : Control = %Mashers

const GOOD_TIME := 3
const BAD_TIME := 6
const bad_delay := 1

var is_bad_running := false
var is_held := false
var current_masher : Masher

const MAX_VALUE = 100

func _ready() -> void:
	$BadTimerStart.start(self.bad_delay)
	self.create_mashers()

func _input(event : InputEvent):
	if event.is_action_pressed("left_mouse"):
		self.is_held = true
		self.mash()
	#if event.is_action_just_pressed("left_mouse"):
		
	if event.is_action_released("left_mouse"):
		self.is_held = false
		
func mash():
	if self.current_masher:
		self.current_masher.click(10)
		
func _process(delta: float) -> void:
	self.current_masher = self.get_current_masher()
	if self.is_held and not self.current_masher:
		self.n_good.value += (delta * (MAX_VALUE / GOOD_TIME))
		
	if self.is_bad_running:
		self.n_bad.value += (delta * (MAX_VALUE / BAD_TIME))
		if self.n_bad.value >= self.n_good.value:
			self.exit()
		
	if self.n_good.value >= MAX_VALUE:
		self.player.add_money(10)
		self.exit()
		
func get_current_masher():
	for masher in self.n_mashers.get_children():
		masher = masher as Masher
		if (self.n_good.value / MAX_VALUE) >= masher.percentage:
			return masher
			
func exit() -> void:
	super()
	self.queue_free()
	

func _on_bad_timer_start_timeout() -> void:
	self.is_bad_running = true
	
	
##############################
func create_mashers():
	var count = randi_range(1, 5)
	for i in range(count):
		var masher = MASHER.instantiate()
		masher.constructor(randi_range(10, 100),randf_range(0.05, 0.95))
		self.n_mashers.add_child(masher)
