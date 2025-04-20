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
@onready var n_mesh = $Mesh
@onready var ui: CanvasLayer = $UI
@onready var n_camera_anchor : CameraAnchor = $CameraAnchor
#@onready var n_fishing_pole : FishingPole = $Hotbar/FishingPole
@onready var n_input : PlayerInput = $Input

@onready var n_hotbar : Hotbar3D = $Hotbar
@onready var n_hotbar_ui : HotbarUI = $UI/Control/Hotbar

@onready var n_ui : UI = $UI/Control/UI
#@onready var n_vignette : Vignette = $Transition/Vignette

@onready var n_money := $UI/Control/Label

var player_grouper : PlayerGrouper
var player_data : PlayerData
var ui_locked = false

func constructor(m_player_data : PlayerData) -> Player:
	self.player_data = m_player_data
	return self

func constructor_node() -> Player:
	
	#await get_tree().process_frame
	
	self.position = Utils.parents(self).filter(func(x): return x is World)[0].n_player_spawn.global_position
	self.player = name.to_int()
	self.player_grouper = self.get_parent()
	
	Game.SyncPlayers.connect(sync_player)
	Signals.UILock.connect(set_ui_lock)
	
	self.sync_player()
	
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
	
func set_ui_lock(lock: bool) -> void:
	self.ui_locked = lock
	#self.n_fishing_pole.active = !lock
	
	
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
	
# Minigame
	
func enter_minigame(mg : Minigame) -> void:
	if !self.is_multiplayer_authority():
		return
	self.n_input.active = false
	self.ui.visible = false
	mg.constructor(self)
	add_child(mg, true)
	mg.Exited.connect(exit_minigame)
	
func exit_minigame() -> void:
	if !self.is_multiplayer_authority():
		return
	self.ui.visible = true
	self.n_input.active = true
	
	
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

	#if not self.player_data.inventory:
		#self.n_ui.n_inventory.add_item(ItemData.new().set_item_type(POLE))
		
		
### Start Dialog
func start_dialog(dialog_resource : DialogueResource):
	if !self.is_multiplayer_authority():
		return
	var balloon = BALLOON.instantiate()
	self.n_ui.add_child(balloon)
	self.ui_locked = true
	balloon.start(dialog_resource, "", [self])
	balloon.tree_exiting.connect(func() :
		self.ui_locked = false
	)
	
### Interact
func interact(interactable : Interactable):
	if !self.is_multiplayer_authority():
		return
	interactable.constructor(self)
	self.add_child(interactable)
	interactable.enter()
	
	self.ui.visible = false
	self.n_input.active = false
	
func end_interact():
	if !self.is_multiplayer_authority():
		return
	self.ui.visible = true
	self.n_input.active = true
