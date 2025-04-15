extends Area3D
class_name DialogArea

@export var dialog : DialogueResource


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.start_dialog(self.dialog)


func _on_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
