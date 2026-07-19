extends Camera3D

@export var target: Node3D # Drag your Player here in the inspector
@export var distance := 12.0
@export var height := 8.0
@export var battle_enemy: Node3D 
@export var rotation_speed := 3.0 # NEW: Controls how fast the camera spins

var current_mode: int = 0 
var locked_rotation := Vector3(deg_to_rad(-30), deg_to_rad(45), 0) 
var yaw := 0.0 # NEW: Stores the current orbital angle in radians

func set_camera_mode(mode: int):
	current_mode = mode

func _physics_process(delta):
	if target == null:
		return
		
	match current_mode:
		0: # FREE_ROAM
			_process_free_roam(delta)
		1: # ROOM_ROAM
			_process_room_roam(delta)
		2: # BATTLE
			_process_battle_cam(delta)

func _process_free_roam(delta):
	# 1. Get the rotation input cleanly from the Input Map
	# This returns -1.0 for left, 1.0 for right, or 0.0 if nothing is pressed
	var rot_input = Input.get_axis("camera_left", "camera_right")
		
	# 2. Update the orbital angle based on input
	yaw += rot_input * rotation_speed * delta
	
	# 3. Calculate the new position in a circle around the player
	var offset = Vector3(0, height, distance).rotated(Vector3.UP, yaw)
	var target_pos = target.global_position + offset
	
	# 4. Move smoothly to the new position and look directly at the player
	global_position = global_position.lerp(target_pos, 5.0 * delta)
	look_at(target.global_position, Vector3.UP)

func _process_room_roam(delta):
	var target_pos = target.global_position
	# Force a fixed 45-degree angle offset so it matches the locked rotation perfectly
	var fixed_offset = Vector3(0, height, distance).rotated(Vector3.UP, deg_to_rad(45))
	target_pos += fixed_offset
	
	global_position = global_position.lerp(target_pos, 5.0 * delta)
	global_rotation = locked_rotation

func _process_battle_cam(delta):
	if battle_enemy == null:
		_process_room_roam(delta) 
		return
		
	var midpoint = (target.global_position + battle_enemy.global_position) / 2.0
	
	# Calculate a fixed battle offset (slightly zoomed out and angled)
	var battle_offset = Vector3(0, height * 1.2, distance * 1.5).rotated(Vector3.UP, deg_to_rad(45))
	var battle_pos = midpoint + battle_offset
	
	global_position = global_position.lerp(battle_pos, 3.0 * delta)
	look_at(midpoint, Vector3.UP)
