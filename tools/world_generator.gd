@tool
extends EditorScript

var base_scene_path = "res://worlds/BaseWorld/base_world.scn"
var new_world_name = "ForestWorld"

# 0: FREE_ROAM
# 1: ROOM_ROAM
# 2: BATTLE
var world_type = 0 

func _run():
	if not FileAccess.file_exists(base_scene_path):
		push_error("Path error: Cannot find " + base_scene_path)
		return

	var snake_name = new_world_name.to_snake_case()
	var base_dir = "res://worlds/" + new_world_name
	var data_dir = base_dir + "/terrain_data"
	var scene_path = base_dir + "/" + snake_name + ".scn"
	
	DirAccess.make_dir_recursive_absolute(base_dir)
	DirAccess.make_dir_recursive_absolute(data_dir)

	var base_packed = load(base_scene_path)
	
	var new_scene = base_packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	new_scene.name = new_world_name
	
	# --- THE NEW INJECTION LOGIC ---
	# We safely check if the root node has the variable, then assign the enum integer
	if "current_mode" in new_scene:
		new_scene.current_mode = world_type
	# -------------------------------
	
	var terrain = new_scene.get_node_or_null("Terrain3D")
	if terrain:
		terrain.data_directory = data_dir

	var packed = PackedScene.new()
	var err = packed.pack(new_scene)
	
	if err == OK:
		ResourceSaver.save(packed, scene_path)
		print("SUCCESS: Scene saved to ", scene_path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("Failed to pack scene: ", err)
