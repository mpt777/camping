extends Node3D
class_name PlayerMesh
### A class for tying in actions to a mesh animations

var avatar : Node3D
var avatar_data : AvatarData
@onready var tree : AnimationTree = $AnimationTree
@export var current_animation : Enums.ANIMATION
var tween : Tween

#class AnimationDirection

func constructor(avatar_data: AvatarData) -> PlayerMesh:
	self.avatar_data = avatar_data
	self.avatar = self.avatar_data.mesh.instantiate()
	self.avatar.rotate_y(deg_to_rad(180))
	add_child(self.avatar)
	self.initialize_tree()
	return self
	
func initialize_tree():
	var anim_player : AnimationPlayer = self.avatar.get_node("AnimationPlayer")
	self.tree.anim_player = anim_player.get_path()
	#anim_player.play(self.avatar_data.animation_lookup[Enums.ANIMATION.WALK])
	self.current_animation = Enums.ANIMATION.IDLE
	self.animate_to(self.current_animation)
	
	
func _physics_process(delta: float) -> void:
	return
	print(self.tree.get("parameters/BlendAmount/blend_amount"))

func animate_to(animation: Enums.ANIMATION): # etween : ETween
	
	if animation == self.current_animation:
		return
		
	var root = self.tree.tree_root.get_node("Root")
	var blend = self.tree.tree_root.get_node("Blend")
	var final_val = 1.0
	
	print("Start-------------------", self.current_animation)
	
	if root.animation != self.avatar_data.animation_lookup[self.current_animation]:
		print("SWAP")
		var root_temp = root
		root = blend
		blend = root_temp
		final_val = 0.0
		
	#print("----------------")
	
	root.animation = self.avatar_data.animation_lookup[self.current_animation]
	blend.animation = self.avatar_data.animation_lookup[animation]
	
	self.current_animation = animation
	print("End", self.current_animation)
	self.tree.active = true
	
	#print(self.tree.get("parameters/BlendAmount/blend_amount"))
	#print(final_val)
	
	var tween = create_tween()
	tween.tween_property(self.tree, "parameters/BlendAmount/blend_amount", final_val, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	# When finsished, reset the postiiosn so we can tween to next one
	tween.tween_callback(func():
		pass
		#print("COMPLETE")
		#root.animation = blend.animation
		#self.tree.set("parameters/BlendAmount/blend_amount", self.get_blend())
	)

func walk():
	pass
	
func run(): 
	pass
	
func emote():
	pass
	
func idle():
	pass
