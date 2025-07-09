extends Node3D
class_name PlayerMesh
### A class for tying in actions to a mesh animationssd

var avatar : Node3D
var avatar_data : AvatarData
@onready var tree : AnimationTree = $AnimationTree
@export var hotbar : Hotbar3D
var current_animation : Enums.ANIMATION
var tween : Tween

var animation_lock : bool = false


#class AnimationDirection

func constructor(avatar_data: AvatarData) -> PlayerMesh:
	self.avatar_data = avatar_data
	self.avatar = self.avatar_data.mesh.instantiate()
	self.avatar.rotate_y(deg_to_rad(180))
	add_child(self.avatar)
	self.initialize_tree()
	self.initialize_hotbar()
	return self
	
func initialize_tree():
	var anim_player : AnimationPlayer = self.avatar.get_node("AnimationPlayer")
	self.tree.anim_player = anim_player.get_path()
	#anim_player.play(self.avatar_data.animation_lookup[Enums.ANIMATION.WALK])
	self.current_animation = Enums.ANIMATION.IDLE
	self.animate_to(self.current_animation)
	self.tree.active = true
	

func initialize_hotbar():
	await get_tree().process_frame
	var remote : RemoteTransform3D = self.avatar.get_node("Armature/Skeleton3D/RightHandBone/RemoteTransform3D")
	remote.remote_path = self.hotbar.n_container.get_path()
	
	
func _physics_process(delta: float) -> void:
	return
	print(self.tree.get("parameters/BlendAmount/blend_amount"))
	

func _blend_animation(animation: Enums.ANIMATION):
	
	if animation == self.current_animation:
		return
		
	var root = self.tree.tree_root.get_node("Root")
	var blend = self.tree.tree_root.get_node("Blend")
	var final_val = 1.0
	#print(self.avatar_data.animation_lookup[animation])
	#self.avatar.get_node("AnimationPlayer").play(self.avatar_data.animation_lookup[animation])
	
	
	#return
	#print(root.animation, " ", self.tree.get("parameters/BlendAmount/blend_amount"))
	#return
	
	#print("Start-------------------", self.current_animation)
	
	if root.animation != self.avatar_data.animation_lookup[self.current_animation]:
		#print("SWAP")sd
		var root_temp = root
		root = blend
		blend = root_temp
		final_val = 0.0
		
	#print("----------------")
	
	root.animation = self.avatar_data.animation_lookup[self.current_animation]
	blend.animation = self.avatar_data.animation_lookup[animation]
	
	self.current_animation = animation

	var tween = create_tween()
	tween.tween_property(self.tree, "parameters/BlendAmount/blend_amount", final_val, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	# When finsished, reset the postiiosn so we can tween to next one
	tween.tween_callback(func():
		pass
		#print("COMPLETE", get_multiplayer_authority(), self.get_parent().name, self)
		#root.animation = blend.animation
		#self.tree.set("parameters/BlendAmount/blend_amount", self.get_blend())
	)

@rpc("call_local", "any_peer", "unreliable", 2)
func sync_animation(animation: Enums.ANIMATION):
	if get_multiplayer_authority() == multiplayer.get_remote_sender_id():
		print("SYNC ANIM", self.name, "owner:", get_multiplayer_authority(), "sender:", multiplayer.get_remote_sender_id(), "animation:", animation, "instance:", multiplayer.get_unique_id())

		_blend_animation(animation)
	
func animate_to(animation: Enums.ANIMATION):
	if !is_multiplayer_authority():
		return
	if animation == self.current_animation:
		return
	print("----------------------------------------------")
	sync_animation.rpc(animation)  # Broadcast to all
	#print("-----------------------", self.name, "owner:", get_multiplayer_authority(), "animation:", animation)

		#print("HERE", " ", multiplayer.get_unique_id())


func walk():
	pass
	
func run(): 
	pass
	
func emote():
	pass
	
func idle():
	pass
