extends Area3D
class_name InteractableArea

@export var interactable : PackedScene

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.interact(self.interactable.instantiate())


func _on_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
