extends CharacterBody3D
class_name Player
		
var POLE = preload("res://scenes/items/tools/fishing_pole/instances/fishing_pole_basic_it.tres")
var BALLOON = preload("res://ui/dialog/balloon.tscn")

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		## Give authority over the player input to the appropriate peer.
		##$PlayerInput.set_multiplayer_authority(id)
		#$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var n_label = $Label3D
@onready var ui: CanvasLayer = $UI
@onready var n_camera_anchor : CameraAnchor = $CameraAnchor

@onready var inputs := $Inputs

@onready var n_hotbar : Hotbar3D = $PlayerMesh/Hotbar
@onready var n_hotbar_ui : HotbarUI = $UI/Control/Hotbar

@onready var player_mesh : PlayerMesh = $PlayerMesh

@onready var n_ui : UI = $UI/Control/UI

@onready var n_money := $UI/Control/Label

var player_grouper : PlayerGrouper
var player_data : PlayerData
var avatar_data : AvatarData

var mouse_mode : Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func constructor(m_player_data : PlayerData) -> Player:
	self.player_data = m_player_data
	return self

func constructor_node() -> Player:
	
	#await get_tree().process_frame
	
	self.avatar_data = load("res://scenes/avatar/zoe/zoe_data.tres")
	
	self.position = Utils.parents(self).filter(func(x): return x is World)[0].n_player_spawn.global_position
	self.player = name.to_int()
	self.player_grouper = self.get_parent()
	
	Game.SyncPlayers.connect(sync_player)
	#Signals.UILock.connect(set_can_move)
	
	self.sync_player()
	
	self.player_mesh.constructor(self.avatar_data)
	
	if player == multiplayer.get_unique_id():
		$CameraAnchor.n_camera.current = true
		self.ui.visible = true
		GlobalUI.transition_out()
		self.deserialize()
	
	return self
	

func sync_player():
	if not self.player in Game.players:
		return
	self.player_data = Game.players[self.player]
	self.render()
	Signals.PlayerLoaded.emit(self.player, self.player_data)
		
func render():
	if self.player_data:
		n_label.text = self.player_data.name
		self.add_money(0)
	
func set_ui(v: bool) -> void:
	self.ui.visible = v
	
func has_menu_open() -> bool:
	if self.ui.visible:
		return true
	return false
	
func add_money(money: int) -> void:
	self.player_data.money += money
	self.n_money.text = "$ " + str(self.player_data.money)
	
func remove_item_from_inventory(item_data : ItemData) -> void:
	self.n_ui.n_inventory.remove_item(item_data)
	self.n_hotbar_ui.remove_item(item_data)
	await get_tree().process_frame
	self.save()
	
func add_item_to_inventory(item_data : ItemData) -> void:
	self.n_ui.n_inventory.add_item(item_data)
	self.save()
	
func add_item_to_hotbar(idx : int, item_data : ItemData) -> void:
	self.n_hotbar_ui.set_item_data(idx, item_data)
	self.save()
	
	
# Inputs	
###################################################

func set_input(codes: Array[String], active) -> void:
	for child in self.inputs.get_children():
		if child.code() in codes:
			child.active = active

func _process(delta: float):
	for child in self.inputs.get_children():
		if child.active:
			child.process(delta)
			
func _physics_process(delta: float) -> void:
	for child in self.inputs.get_children():
		if child.active:
			child.physics_process(delta)
	
###################################################	
# Minigame
	
func enter_minigame(mg : Minigame) -> void:
	if !self.is_multiplayer_authority():
		return
	self.set_ui(false)
	self.set_input(["movement"], false)
	mg.constructor(self)
	add_child(mg, true)
	mg.Exited.connect(exit_minigame)
	
func exit_minigame() -> void:
	if !self.is_multiplayer_authority():
		return
	self.set_ui(false)
	self.set_input(["movement"], true)
	
	
####################################################################################################
func save() -> void:
	if !self.is_multiplayer_authority():
		return
	self.player_data.inventory = self.n_ui.n_inventory.serialize()
	self.player_data.hotbar = self.n_hotbar_ui.serialize()
	Serializer.write_json(PlayerData.save_path(self.player_data.name), self.player_data.serialize())
	
func deserialize() -> void:
	if !self.is_multiplayer_authority():
		return
	if !(self.n_ui.n_inventory.AddToHotbar.is_connected(add_item_to_hotbar)):
		self.n_ui.n_inventory.AddToHotbar.connect(add_item_to_hotbar)
	
	self.n_ui.n_inventory.deserialize(self.player_data.inventory)
	self.n_hotbar_ui.deserialize(self.player_data.hotbar)
	self.n_hotbar_ui.update()

	if not self.player_data.inventory:
		self.n_ui.n_inventory.add_item(FishingPoleData.new().set_item_type(POLE))
		
		
### Start Dialog
func start_dialog(dialog_resource : DialogueResource):
	if !self.is_multiplayer_authority():
		return
	var balloon = BALLOON.instantiate()
	self.n_ui.add_child(balloon)
	
	self.set_input(["movement"], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	balloon.start(dialog_resource, "", [self])
	balloon.tree_exiting.connect(func() :
		self.set_input(["movement"], true)
		Input.set_mouse_mode(self.mouse_mode)
	)
	
### Interact #############################################
func interact(interactable : Interactable):
	if !self.is_multiplayer_authority():
		return
	interactable.constructor(self)
	self.add_child(interactable)
	interactable.enter()
	
	self.ui.visible = false
	
	self.set_input(["movement", "ui"], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#self.n_input.active = false
	
func end_interact():
	if !self.is_multiplayer_authority():
		return
	self.ui.visible = true
	self.set_input(["movement", "ui"], true)
	Input.set_mouse_mode(self.mouse_mode)
	#self.n_input.active = true
