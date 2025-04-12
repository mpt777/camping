extends Minigame
class_name MGFishing


const MASHER = preload("res://scenes/minigames/fishing/masher/masher.tscn")

@onready var n_good : ProgressBar = %BarGood
@onready var n_bad : ProgressBar = %BarBad
@onready var n_mashers : Control = %Mashers

const GOOD_TIME := 3.0
const BAD_TIME := 10.0
const bad_delay := 2.0

var is_bad_running := false
var is_held := false
var current_masher : Masher

var current_fish : FishData

const MAX_VALUE := 100.0

func _ready() -> void:
	$BadTimerStart.start(self.bad_delay)
	self.current_fish = Game.FISH.new().constructor(Game.FISH_TYPE)
	self.create_mashers()

func _input(event : InputEvent):
		
	if event.is_action_pressed("left_mouse"):
		self.mash()
	#if event.is_action_just_pressed("left_mouse"):
		
		
func mash():
	if self.current_masher:
		self.current_masher.click(10)
		
func _process(delta: float) -> void:
	
	self.is_held = Input.is_action_pressed("left_mouse")
	
		
	self.current_masher = self.get_current_masher()
	if self.is_held and not self.current_masher:
		self.n_good.value += (delta * (MAX_VALUE / GOOD_TIME))
		
	if self.is_bad_running:
		self.n_bad.value += (delta * (MAX_VALUE / BAD_TIME))
		if self.n_bad.value >= self.n_good.value:
			self.exit()
		
	if self.n_good.value >= MAX_VALUE:
		self.player.add_item_to_inventory(self.current_fish)
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
		self.n_mashers.add_child(masher)
