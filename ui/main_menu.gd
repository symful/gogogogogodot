extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var load_button = $VBoxContainer/LoadButton

func _ready():
	show()
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)

func _on_start_button_pressed():
	print("Starting New Game...")
	GameManager.start_new_game()
	hide()

func _on_load_button_pressed():
	var save_menu = get_parent().get_node("SaveMenu")
	if save_menu:
		# Open the menu in "load" mode
		save_menu.open_menu("load")
