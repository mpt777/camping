extends CharacterBody3D
class_name Player
		
# Get the gravity from the project settings to be synced with RigidBody nodes.

#const FISHING_POLE = preload("res://scenes/items/tools/fishing_pole/fishing_pole.tscn")

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

@onready var n_ui : UserInterface = $UI/Control/UI

@onready var n_money := $UI/Control/Label

var player_grouper : PlayerGrouper
var player_data : PlayerData
var ui_locked = false

func constructor(m_player_data : PlayerData) -> Player:
	self.player_data = m_player_data
	return self

func constructor_node() -> Player:
	self.position = Utils.parents(self).filter(func(x): return x is World)[0].n_player_spawn.global_position
	self.player = name.to_int()
	self.player_grouper = self.get_parent()
	
	Game.SyncPlayers.connect(sync_player)
	Signals.UILock.connect(set_ui_lock)
	
	if player == multiplayer.get_unique_id():
		$CameraAnchor.n_camera.current = true
		self.ui.visible = true
		
	self.sync_player()
	#self.n_fishing_pole.constructor(self)
	return self
	

func sync_player():
	if self.player in Game.players:
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
	
func add_item_to_inventory(item_data : ItemData) -> void:
	self.n_ui.n_inventory.add_item(item_data)
	
# Minigame
	
func enter_minigame(mg : Minigame) -> void:
	self.n_input.active = false
	self.ui.visible = false
	mg.constructor(self)
	add_child(mg, true)
	mg.Exited.connect(exit_minigame)
	
func exit_minigame() -> void:
	self.ui.visible = true
	self.n_input.active = true
