@tool
extends EditorScript

var base_scene_path = "res://worlds/BaseWorld/base_world.scn"
var new_world_name = "DesertWorld"
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
	
	# --- THIS IS THE MAGIC FIX ---
	# Passing GEN_EDIT_STATE_INSTANCE safely maintains all correct ownership flags.
	# It prevents instanced scenes from duplicating and ignores temporary plugin nodes.
	var new_scene = base_packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	new_scene.name = new_world_name
	# -----------------------------
	
	var terrain = new_scene.get_node_or_null("Terrain3D")
	if terrain:
		# 1. UNIQUE DATA: Keep this so sculpting and painted splatmaps remain unique per world
		terrain.data_directory = data_dir
		
		# 2. UNIQUE MATERIAL: (Optional) Keep this ONLY if you want different 
		# shader settings (like different water colors or macro variations) per world.
		if terrain.material:
			var new_mat = terrain.material.duplicate(true)
			var mat_path = base_dir + "/" + snake_name + "_material.tres"
			ResourceSaver.save(new_mat, mat_path)
			terrain.material = load(mat_path)

	var packed = PackedScene.new()
	var err = packed.pack(new_scene)
	
	if err == OK:
		ResourceSaver.save(packed, scene_path)
		print("SUCCESS: Scene saved to ", scene_path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("Failed to pack scene: ", err)

# NOTE: The _clear_owner_recursive and _set_owner_recursive functions 
# have been completely deleted! You no longer need them.
