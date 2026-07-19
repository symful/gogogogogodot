extends Button

@onready var location_label = $MarginContainer/HBoxContainer/VBoxContainer/LocationLabel
@onready var playtime_label = $MarginContainer/HBoxContainer/VBoxContainer/PlaytimeLabel
@onready var timestamp_label = $MarginContainer/HBoxContainer/TimestampLabel

var slot_data: Dictionary = {}

func _ready():
	# Set pivot to the center so it scales cleanly
	pivot_offset = size / 2.0
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	pressed.connect(_on_press)
	
var current_mode: String = "save"

# 1. Update set_data to accept the mode
func set_data(data: Dictionary, mode: String):
	slot_data = data
	current_mode = mode
	if data.is_empty():
		location_label.text = "EMPTY SLOT"
		playtime_label.text = "--:--"
		timestamp_label.text = ""
	else:
		location_label.text = data["metadata"]["location_name"].to_upper()
		var pt = int(data["metadata"]["playtime"])
		playtime_label.text = "PT: %02d:%02d" % [pt / 60, pt % 60]
		timestamp_label.text = data["metadata"]["timestamp"]

# 2. Update the click function to handle both actions
func _on_press():
	if current_mode == "save":
		print("Saving game...")
		GameManager.save_game()
		# Refresh the menu to show the updated file data immediately
		get_parent().get_parent()._refresh_slots() 
		
	elif current_mode == "load":
		if not slot_data.is_empty():
			print("Loading game...")
			var pos = slot_data["player"]
			var load_pos = Vector3(pos["pos_x"], pos["pos_y"], pos["pos_z"])
			GameManager.load_saved_game(slot_data["world"]["path"], load_pos)
			
			# Hide both the Save Menu and the Main Menu
			get_parent().get_parent().hide()
			get_parent().get_parent().get_parent().get_node("MainMenu").hide()
		else:
			print("Empty slot, nothing to load!")

# Spring physics for a highly tactile UI feel
func _on_hover():
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.25)
	# Note: The color inversion is handled automatically by the Hover StyleBoxFlat

func _on_unhover():
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
