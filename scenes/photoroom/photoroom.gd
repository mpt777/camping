extends Node

@onready var n_captured_image = $Button

func _on_button_button_up() -> void:
	n_captured_image.visible = false
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var date = Time.get_date_string_from_system().replace(".","_") 
	var time :String = Time.get_time_string_from_system().replace(":","")
	DirAccess.make_dir_absolute("user://screenshots/")  
	var screenshot_path = "user://screenshots/" + "screenshot_" + date+ "_" + time + ".jpg" # the path for our screenshot.
	var image = get_viewport().get_texture().get_image() # We get what our player sees
	print("Saved!")
	image.save_jpg(screenshot_path)
	n_captured_image.visible = true
