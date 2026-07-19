extends Control

const SAVE_FILE_PATH = "user://savegame.save"
var save_slot_scene = preload("res://ui/save_slot.scn") # UPDATE THIS TO YOUR ACTUAL PATH

@onready var slot_container = $SlotContainer

# Inside save_menu.gd
var current_mode = "save" # Default state

# 1. Update this function to accept the mode
func open_menu(mode: String):
	current_mode = mode
	show()
	_refresh_slots()

func _refresh_slots():
	for child in slot_container.get_children():
		child.queue_free()
		
	var file_data = _read_save_file()
	var slot = save_slot_scene.instantiate()
	slot_container.add_child(slot)
	
	# 2. Pass the data AND the mode to the slot component
	slot.set_data(file_data, current_mode)

func _read_save_file() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return {}
		
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data
	else:
		push_error("JSON Parse Error at line ", json.get_error_line(), ": ", json.get_error_message())
		return {}

func _unhandled_input(event):
	# Allow the player to close the menu easily
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
