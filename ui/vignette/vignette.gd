extends ColorRect
class_name Vingette

#@export var center : Vector2
#@export var radius : float
#@export var softness : int
#@export var vignette_color : Color
@export var pause_mode : Tween.TweenPauseMode = Tween.TWEEN_PAUSE_BOUND 

signal CirleIn
signal CirleOut
signal Finished

var center : Vector2 :
	set(value):
		center = value
		self.set_center()

func constructor(p_center : Vector2, screen_to_uv:=true, n_pause_mode:=Tween.TWEEN_PAUSE_PROCESS) -> Vingette:
	var c = p_center 
	if screen_to_uv:
		c = self.screen_to_uv(c)
	self.pause_mode = n_pause_mode
	self.Finished.connect(func(): self.queue_free())
	self.center = c
	return self

func full_constructor(p_center : Vector2, screen_to_uv:=true, out:=false, n_pause_mode:=Tween.TWEEN_PAUSE_PROCESS) -> Vingette:
	GlobalUI.add_child(self)
	self.constructor(p_center, screen_to_uv, n_pause_mode)
	if out:
		self.circle_out()
	else:
		self.circle_in()
	return self

func _ready():
	self.material = self.material.duplicate()
	self.set_shader_color(Color.AQUA)
	
func set_shader_color(p_color : Color):
	get_material().set_shader_parameter("color", p_color)

func screen_to_uv(p_center : Vector2) -> Vector2:
	return p_center / GlobalUI.get_viewport_rect().size
	
func screen_center() -> Vector2:
	return GlobalUI.get_viewport_rect().size / 2

func set_center() -> void:
	get_material().set_shader_parameter("center", self.center)
	
func blank_screen(center: Vector2 = Vector2(0.5, 0.5)) -> void:
	self.center = center
	get_material().set_shader_parameter("diameter_factor", 0)

func set_circle_in(center: Vector2 = Vector2(0.5, 0.5)) -> void:
	self.center = center
	self.circle_in()
	
func circle_in() -> void:
	var t = Game.get_tree().create_tween()
	t.tween_method(
		func(x): 
			get_material().set_shader_parameter("diameter_factor", x), 1.5, -0.5, 1.0
	).set_trans(Tween.TRANS_LINEAR)
	t.set_pause_mode(self.pause_mode)
	await t.finished
	Finished.emit()
	CirleIn.emit()
	
func set_circle_out(center: Vector2 = Vector2(0.5, 0.5)) -> void:
	self.center = center
	self.circle_out()
	
func circle_out() -> void:
	var t = Game.get_tree().create_tween()
	t.tween_method(
		func(x): get_material().set_shader_parameter("diameter_factor", x), -0.5, 1.5, 1.0
	).set_trans(Tween.TRANS_LINEAR)
	t.set_pause_mode(self.pause_mode)
	await t.finished
	Finished.emit()
	CirleOut.emit()
