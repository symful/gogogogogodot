@tool
extends EditorScript

# --- CONFIGURATION ---
var models_dir = "res://assets/environments/models"
var base_object_path = "res://objects/BaseObject/base_object.scn"
var output_base_dir = "res://objects"
# ---------------------

func _run():
	print("--- Starting Master Generation V3 ---")
	
	var base_scene = load(base_object_path) as PackedScene
	if not base_scene:
		push_error("Cannot find BaseObject!")
		return
		
	var dir = DirAccess.open(models_dir)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".obj") and not file_name.ends_with(".import"):
			_process_master(file_name, base_scene)
		file_name = dir.get_next()
		
	EditorInterface.get_resource_filesystem().scan()
	print("--- Finished! Textures and Exact Physics generated. ---")

func _process_master(obj_file_name: String, base_scene: PackedScene):
	var base_name = obj_file_name.replace(".obj", "")
	var category = base_name.split("_")[0] 
	var target_dir = output_base_dir + "/" + category
	DirAccess.make_dir_recursive_absolute(target_dir)
	
	var new_object = base_scene.instantiate()
	new_object.name = base_name.to_pascal_case()
	
	# Clean up ghost nodes
	for child in new_object.get_children():
		if child is StaticBody3D or child is CollisionShape3D:
			child.free()
	
	var mesh_instance = _get_mesh_instance(new_object)
	
	var obj_path = models_dir + "/" + obj_file_name
	var loaded_obj = load(obj_path)
	
	# Handle both ways Godot might import the .obj file
	if loaded_obj is PackedScene:
		var temp = loaded_obj.instantiate()
		var temp_mesh = _get_mesh_instance(temp)
		if temp_mesh and temp_mesh.mesh:
			mesh_instance.mesh = temp_mesh.mesh.duplicate(true)
		temp.free()
	elif loaded_obj is Mesh:
		mesh_instance.mesh = loaded_obj.duplicate(true)

	# Catch errors instead of failing silently
	if not mesh_instance.mesh:
		push_error("CRITICAL: Failed to extract mesh from ", obj_file_name, " - Check your import settings!")
		new_object.free()
		return
		
	# 1. PARSE MTL & FIX TEXTURES
	var mtl_file = obj_file_name.replace(".obj", ".mtl")
	var mtl_path = models_dir + "/" + mtl_file
	var custom_materials = _parse_mtl(mtl_path, target_dir, base_name)
	
	for i in range(mesh_instance.mesh.get_surface_count()):
		var orig_mat = mesh_instance.mesh.surface_get_material(i)
		
		# Godot preserves the material name (e.g., "Bark_NormalTree") even if textures fail
		if orig_mat and orig_mat.resource_name != "" and custom_materials.has(orig_mat.resource_name):
			mesh_instance.set_surface_override_material(i, custom_materials[orig_mat.resource_name])
		elif i < custom_materials.values().size():
			# Fallback mapping
			mesh_instance.set_surface_override_material(i, custom_materials.values()[i])

	# 2. EXACT TRIMESH PHYSICS
	var lower_name = base_name.to_lower()
	var is_walkable = "grass" in lower_name or "flower" in lower_name or "petal" in lower_name or "mushroom" in lower_name or "pebble" in lower_name or "clover" in lower_name
	
	if not is_walkable:
		var static_body = StaticBody3D.new()
		static_body.name = "StaticBody3D"
		var collision = CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		
		# create_trimesh_shape() perfectly traces the mesh geometry.
		# Since it's attached directly to the mesh, it requires zero position offset!
		collision.shape = mesh_instance.mesh.create_trimesh_shape()
		
		static_body.add_child(collision)
		mesh_instance.add_child(static_body)

	# 3. SAVE SCENE
	_set_owner_recursive(new_object, new_object)
	var scene_path = target_dir + "/" + base_name.to_snake_case() + ".scn"
	var packed = PackedScene.new()
	packed.pack(new_object)
	ResourceSaver.save(packed, scene_path)
	
	print("Generated: ", base_name)
	new_object.free()

# --- MTL PARSER ---
func _parse_mtl(mtl_path: String, save_dir: String, base_name: String) -> Dictionary:
	var materials = {}
	if not FileAccess.file_exists(mtl_path): return materials
		
	var file = FileAccess.open(mtl_path, FileAccess.READ)
	var current_mat: StandardMaterial3D = null
	var current_name := ""
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		if line.begins_with("newmtl "):
			current_name = line.replace("newmtl ", "").strip_edges()
			current_mat = StandardMaterial3D.new()
			current_mat.resource_name = current_name
			current_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			materials[current_name] = current_mat
			
		elif line.begins_with("map_Kd ") and current_mat != null:
			# Extracts 'Leaves_TwistedTree_C.png' from 'C:/Leaves_TwistedTree_C.png'
			var tex_filename = line.replace("map_Kd ", "").strip_edges().get_file() 
			var tex_path = models_dir + "/" + tex_filename
			
			if FileAccess.file_exists(tex_path):
				current_mat.albedo_texture = load(tex_path)
				var lower_tex = tex_filename.to_lower()
				
				# Smart transparency
				if "leaf" in lower_tex or "leaves" in lower_tex or "flower" in lower_tex or "bush" in lower_tex:
					current_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
					current_mat.alpha_scissor_threshold = 0.5
					current_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
					
		elif line.begins_with("map_Bump ") and current_mat != null:
			# Some of your files have normal maps (e.g. Bark_NormalTree_Normal.png)! This extracts them.
			var parts = line.split(" ", false)
			var tex_filename = parts[parts.size() - 1].get_file()
			var tex_path = models_dir + "/" + tex_filename
			
			if FileAccess.file_exists(tex_path):
				current_mat.normal_enabled = true
				current_mat.normal_texture = load(tex_path)

	# Save the generated materials to disk
	for mat_name in materials.keys():
		var mat = materials[mat_name]
		var safe_name = mat_name.to_snake_case().replace("/", "_").replace("\\", "_")
		var mat_path = save_dir + "/" + base_name.to_snake_case() + "_" + safe_name + ".tres"
		ResourceSaver.save(mat, mat_path)
		materials[mat_name] = load(mat_path)

	return materials

# --- HELPER FUNCTIONS ---
func _get_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	for child in node.get_children():
		var result = _get_mesh_instance(child)
		if result: return result
	return null

func _set_owner_recursive(node: Node, root_node: Node):
	if node != root_node: node.owner = root_node
	for child in node.get_children(): _set_owner_recursive(child, root_node)
