extends Node

# These will be assigned by the Main scene when the game starts
var world_container: Node3D
var player: CharacterBody3D

var playtime: float = 0.0
var current_location_name: String = "Unknown Region"

const SAVE_FILE_PATH = "user://savegame.save"
const NEW_GAME_WORLD = "res://worlds/ForestWorld/forest_world.scn"
const NEW_GAME_SPAWN_POS = Vector3(10, 20, 10) 

var current_world: Node3D = null

func start_new_game():
	_transition_to_world(NEW_GAME_WORLD, "", NEW_GAME_SPAWN_POS)
	_update_location_name()
	
func load_saved_game(saved_world_path: String, saved_position: Vector3):
	_transition_to_world(saved_world_path, "", saved_position)
	_update_location_name()

func warp_to_new_area(new_world_path: String, target_warp_name: String):
	_transition_to_world(new_world_path, target_warp_name, Vector3.ZERO)
	_update_location_name()

# Consolidate the name checking to avoid instantiating ghost worlds
func _update_location_name():
	if current_world and "location_name" in current_world:
		current_location_name = current_world.location_name
	else:
		current_location_name = "Unknown Region"

# The core engine that swaps levels
func _transition_to_world(world_path: String, target_warp_name: String, fallback_pos: Vector3):
	if current_world:
		current_world.queue_free()
		await current_world.tree_exited 
		
	var next_world_scene = load(world_path) as PackedScene
	current_world = next_world_scene.instantiate()
	world_container.add_child(current_world)
	
	if target_warp_name != "":
		# 1. Find the Warp Point (Area3D)
		var warp_node = current_world.find_child(target_warp_name, true, false)
		if warp_node:
			# 2. Grab the SpawnPosition (Marker3D) specifically from INSIDE that Warp Point
			var spawn_pos = warp_node.get_node_or_null("SpawnPosition")
			if spawn_pos and spawn_pos is Marker3D:
				player.global_position = spawn_pos.global_position
				player.global_rotation = spawn_pos.global_rotation
			else:
				push_error("FAILED: 'SpawnPosition' missing inside warp point: ", target_warp_name)
		else:
			push_error("FAILED: Could not find warp point named: ", target_warp_name)
	else:
		player.global_position = fallback_pos
		
	# Unpause the player now that the ground exists
	player.set_physics_process(true)

func _process(delta):
	# Track playtime in seconds
	playtime += delta

func save_game():
	var save_data = {
		"metadata": {
			"location_name": current_location_name,
			"playtime": playtime,
			"timestamp": Time.get_datetime_string_from_system()
		},
		"world": {
			"path": current_world.scene_file_path if current_world else NEW_GAME_WORLD,
		},
		"player": {
			"pos_x": player.global_position.x,
			"pos_y": player.global_position.y,
			"pos_z": player.global_position.z
		}
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		# Format with indents for easier debugging if you read the raw JSON
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved successfully to: ", SAVE_FILE_PATH)
	else:
		push_error("Failed to write save file.")
