extends PanelContainer
class_name MessageContainer

const MESSAGE_UI = preload("res://ui/messaging/message_ui/message_ui.tscn")

@onready var n_messages : VBoxContainer = %Messages
@onready var n_text : LineEdit = %TextEdit

const modulate_hidden : Color = Color("ffffff9e")
const modulate_shown : Color = Color("ffffff")
var active : bool = false

func _ready():
	Signals.AddMessageToBox.connect(add_message)
	self.ready.connect(_on_ready)
	
	self.modulate = self.modulate_hidden
	
func _on_ready():
	self.set_multiplayer_authority(self.get_parent().get_multiplayer_authority())
	
func add_message(message : Message):
	var message_ui : MessageUI = MESSAGE_UI.instantiate().constructor(message)
	n_messages.add_child(message_ui, true)
	message_ui.render()
	
	await get_tree().process_frame
	var scroll: ScrollContainer = self.n_messages.get_parent()
	scroll.set_deferred("scroll_vertical", 10000)
	

func activate():
	Signals.SetInputMode.emit(["movement", "camera", "ui"], false)
	self.modulate = self.modulate_shown
	self.active = true
	
func deactive():
	Signals.SetInputMode.emit(["movement", "camera", "ui"], true)
	self.modulate = self.modulate_hidden
	self.active = false
	

# Text Input
func _on_text_edit_focus_entered() -> void:
	if is_multiplayer_authority():
		self.activate()

func _on_text_edit_focus_exited() -> void:
	if is_multiplayer_authority():
		self.deactive()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("exit") and self.active:
			accept_event()
			self.deactive()
			n_text.release_focus()

func _on_text_edit_text_submitted(new_text: String) -> void:
	Signals.AddMessage.emit(Message.new().constructor(new_text, [0]))
	self.n_text.text = ""
	#self.n_text.grab_focus()
	#self.n_text.grab_click_focus()
