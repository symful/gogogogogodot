extends Area3D

var player_in_zone = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if body.name == "Player":
		player_in_zone = true

func _on_body_exited(body: Node3D):
	if body.name == "Player":
		player_in_zone = false

func _unhandled_input(event):
	if player_in_zone and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled() 
		
		# We must navigate from the 3D world up to the UILayer in Main
		# A cleaner way is using an Autoload for UI, but this works immediately:
		var main_node = get_tree().root.get_node("MainScene")
		var save_menu = main_node.get_node("UILayer/SaveMenu")
		
		if save_menu:
			save_menu.open_menu("save") # Add "save" here!
