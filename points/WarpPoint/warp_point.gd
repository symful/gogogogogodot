extends Area3D

@export_file("*.scn") var target_world_path: String
@export var target_point_name: String = ""
@export var location_name: String = "Unknown Region"

@export_enum("Micro (Instant/Fast)", "Macro (Fade/Load)") var warp_type: int = 1

# Track if the player is close enough to interact
var player_in_zone = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if body.name == "Player":
		player_in_zone = true
		print(">> WARP ZONE REACHED - Press 'interact' to travel")

func _on_body_exited(body: Node3D):
	if body.name == "Player":
		player_in_zone = false

func _unhandled_input(event):
	# Check if the player is in the zone and hits the interact button
	if player_in_zone and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled() 
		
		if target_world_path == "":
			push_warning("Warp Point missing target path!")
			return
			
		# Update the GameManager's metadata before warping
		GameManager.current_location_name = location_name
		
		if warp_type == 0:
			print("Executing fast micro-warp...")
		else:
			print("Executing heavy macro-warp...")
			
		GameManager.warp_to_new_area(target_world_path, target_point_name)
