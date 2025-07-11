extends PanelContainer
class_name MessageContainer

const MESSAGE_UI = preload("res://ui/message_ui/message_ui.tscn")

@onready var n_messages : VBoxContainer = %Messages
@onready var n_text : LineEdit = %TextEdit

func _ready():
	Signals.AddMessageToBox.connect(add_message)
	
func _enter_tree() -> void:
	self.set_multiplayer_authority(multiplayer.get_unique_id())
	
func add_message(message : Message):
	var message_ui : MessageUI = MESSAGE_UI.instantiate().constructor(message.message, message.color)
	n_messages.add_child(message_ui, true)
	message_ui.render()
	self.n_messages.get_parent().scroll_vertical = INF

# Text Input
func _on_text_edit_focus_entered() -> void:
	if is_multiplayer_authority():
		Signals.UILock.emit(false)

func _on_text_edit_focus_exited() -> void:
	if is_multiplayer_authority():
		Signals.UILock.emit(true)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("exit"):
			Signals.UILock.emit(true)
			n_text.release_focus()

func _on_text_edit_text_submitted(new_text: String) -> void:
	Signals.AddMessage.emit(Message.new().constructor(new_text, [0]))
	self.n_text.text = ""
