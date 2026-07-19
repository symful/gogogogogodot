extends CharacterBody3D

@export var speed := 5.0
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var state := "idle"
var direction := "down"

func _ready():
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y 
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD

func _physics_process(delta):
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_2d := Input.get_vector("left", "right", "up", "down")

	var cam_forward := -camera.global_transform.basis.z
	var cam_right := camera.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()

	var move_dir := Vector3.ZERO
	move_dir += cam_forward * (-input_2d.y)
	move_dir += cam_right * input_2d.x
	move_dir = move_dir.normalized()

	var is_moving := move_dir != Vector3.ZERO

	# Lock movement if attacking
	if state == "attack1" or state == "attack2":
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
		return # Let the attack finish

	if is_moving:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
		direction = get_direction_relative_to_camera(move_dir)
		state = "run"
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		state = "idle"
		
	move_and_slide()

	if Input.is_action_just_pressed("attack1"):
		state = "attack1"
	elif Input.is_action_just_pressed("attack2"):
		state = "attack2"

	# Dynamically play the correct animation (e.g., "run_down")
	var anim_name = state + "_" + direction
	sprite.play(anim_name)

# --- Connecting the Combat Hitboxes Later ---
# We will use this built-in signal function to turn hitboxes on and off via code!
func _on_animated_sprite_3d_frame_changed():
	if state == "attack1":
		if sprite.frame == 3:
			pass # Turn hitbox ON
		elif sprite.frame == 6:
			pass # Turn hitbox OFF

# Reset to idle when the attack animation finishes
func _on_animated_sprite_3d_animation_finished():
	if state == "attack1" or state == "attack2":
		state = "idle"

func get_direction_relative_to_camera(move_dir: Vector3) -> String:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return direction 

	var cam_forward := -camera.global_transform.basis.z
	var cam_right := camera.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()

	var forward_amount := move_dir.dot(cam_forward)
	var right_amount := move_dir.dot(cam_right)
	var abs_forward: float = abs(forward_amount)
	var abs_right: float = abs(right_amount)

	if abs(abs_forward - abs_right) < 0.1:
		if direction == "up" and forward_amount > 0: return "up"
		if direction == "down" and forward_amount < 0: return "down"
		if direction == "right" and right_amount > 0: return "right"
		if direction == "left" and right_amount < 0: return "left"

	if abs_forward > abs_right:
		return "up" if forward_amount > 0 else "down"
	else:
		return "right" if right_amount > 0 else "left"
