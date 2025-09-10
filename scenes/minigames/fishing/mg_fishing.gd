extends Minigame
class_name MGFishing

const FISH_DATA = preload("res://scenes/items/fish/fish_data.gd")
const FISH_TYPE = preload("res://scenes/items/fish/fish/golden_trout.tres")
const MASHER = preload("res://scenes/minigames/fishing/masher/masher.tscn")

@onready var n_pole : PanelContainer = %Pole
@onready var n_good : ProgressBar = %BarGood
@onready var n_bad : ProgressBar = %BarBad
@onready var n_mashers : Control = %Mashers

const GOOD_TIME := 3.0
const BAD_TIME := 10.0
const bad_delay := 2.0

var success = false

var is_bad_running := false
var is_held := false
var is_held_old := false

var is_not_held_time : float = 100.0 # Used to start the pole down
var _last_tween_target: float = -1.0
var current_masher : Masher

var current_fish : FishData
var rot_tween : Tween

const MAX_VALUE := 100.0

# BAD DESIGN. TWEEN BETWEEN -15, since that is what is set

func _ready() -> void:
	$BadTimerStart.start(self.bad_delay)
	self.current_fish = FISH_DATA.new().constructor(FISH_TYPE)
	self.create_mashers()

func _input(event : InputEvent):
	
	if event.is_action_pressed("left_mouse"):
		self.mash()
	#if event.is_action_just_pressed("left_mouse"):
		
		
func mash() -> void:
	if self.current_masher:
		self.current_masher.click(1000)
		
func animate(force_rotation : float = 0.0) -> void:
	var tween_to : float = 10.0
	if force_rotation:
		tween_to = force_rotation

	print(tween_to)
	# Prevent unnecessary restarts
	if self._last_tween_target == tween_to:
		return
	self._last_tween_target = tween_to

	if rot_tween and rot_tween.is_valid():
		rot_tween.kill()

	rot_tween = create_tween()
	rot_tween.tween_property(
		self.n_pole,
		"rotation",
		deg_to_rad(tween_to),
		1
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	
		
func _process(delta: float) -> void:
	self.is_held_old = self.is_held
	self.is_held = Input.is_action_pressed("left_mouse")
	
	if self.is_held:
		self.is_not_held_time = 0.0
	else:
		self.is_not_held_time += delta
		
	if not self.is_held and self.is_not_held_time >= 0.25:
		self.animate(15.0)
	else:
		self.animate()
			
	self.current_masher = self.get_current_masher()
	if self.is_held and not self.current_masher:
		self.n_good.value += (delta * (MAX_VALUE / GOOD_TIME))
		
	if self.is_bad_running:
		self.n_bad.value += (delta * (MAX_VALUE / BAD_TIME))
		if self.n_bad.value >= self.n_good.value:
			self.exit()
		
	if self.n_good.value >= MAX_VALUE:
		#self.player.add_item_to_inventory(self.current_fish)
		self.success = true
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
func is_too_close(array : Array, target : float, tolerance: float) -> bool:
	for i in array:
		if abs(i - target) < tolerance:
			return true
	return false
	
func find_value(array : Array, bounds : Array, tolerance: float) -> float:
	var value_to_check = randf_range(bounds[0], bounds[1])
	for i in range(100):
		value_to_check = randf_range(bounds[0], bounds[1])
		if is_too_close(array, value_to_check, tolerance):
			continue
		return value_to_check
	return value_to_check
	
func create_mashers():
	var difficulty_breadth = int(log(self.current_fish.get_difficulty_breadth() * 0.5 + 1))
	var difficulty_depth = self.current_fish.get_difficulty_depth()
	
	var positions = []
	
	#print({
		#"diff_depth": self.current_fish.fish_type.difficulty_depth,
		#"diff_breadth": self.current_fish.fish_type.difficulty_breadth,
		#"breadth" : self.current_fish.get_difficulty_breadth(),
		#"depth" : self.current_fish.get_difficulty_depth(),
		#"price": self.current_fish.price,
		#"size": self.current_fish.size.value,
		#"quality": self.current_fish.quality.value,
	#})
	
	var count = randi_range(1,  difficulty_breadth + 2)
	for i in range(count):
		var masher = MASHER.instantiate()
		var pos = find_value(positions, [0.1, 0.90], 0.1)
		positions.append(pos)
		masher.constructor(
			ceil(randf_range(0.5, 1.2) * (difficulty_depth / count)),
		 	pos
		)
		self.n_mashers.add_child(masher, true)
