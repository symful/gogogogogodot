extends CharacterBody3D

@export var speed := 5.0
@export var attack_speed_multiplier := 0.5  # Movement speed while attacking (0.5 = half speed)
@export var attack_animation_speed := 2.0   # How fast the attack animation plays (2.0 = twice as fast)

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var state := "idle"
var direction := "down"

func _ready():
	# Visual setup
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	
	# Force attacks to be non-looping
	sprite.sprite_frames.set_animation_loop("attack1", false)
	sprite.sprite_frames.set_animation_loop("attack2", false)
	
	# Connect signals in code
	sprite.animation_finished.connect(_on_animated_sprite_3d_animation_finished)
	sprite.frame_changed.connect(_on_animated_sprite_3d_frame_changed)

func _physics_process(delta):
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Input
	var input_2d := Input.get_vector("left", "right", "up", "down")

	# Camera-relative movement directions
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

	# Determine current speed (reduced if attacking)
	var current_speed = speed
	if state == "attack1" or state == "attack2":
		current_speed = speed * attack_speed_multiplier

	# --- Movement (always runs) ---
	if is_moving:
		velocity.x = move_dir.x * current_speed
		velocity.z = move_dir.z * current_speed
		direction = get_direction_relative_to_camera(move_dir)
		if state != "attack1" and state != "attack2":
			state = "run"
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		if state != "attack1" and state != "attack2":
			state = "idle"

	move_and_slide()

	# --- Attack Input (only if not already attacking) ---
	if state != "attack1" and state != "attack2":
		if Input.is_action_just_pressed("attack1"):
			state = "attack1"
		elif Input.is_action_just_pressed("attack2"):
			state = "attack2"

	# --- ADJUST SPEED SCALE FOR FASTER ATTACKS ---
	if state == "attack1" or state == "attack2":
		sprite.speed_scale = attack_animation_speed
	else:
		sprite.speed_scale = 1.0  # Normal speed for idle/run

	# --- Play the correct animation ---
	var anim_name = state + "_" + direction
	sprite.play(anim_name)

# --- Reset to idle when attack finishes ---
func _on_animated_sprite_3d_animation_finished():
	if state == "attack1" or state == "attack2":
		state = "idle"
		# Instantly switch to idle so it doesn't freeze on the last frame
		sprite.play("idle_" + direction)

# --- Hitbox control via animation frame events ---
func _on_animated_sprite_3d_frame_changed():
	if state == "attack1":
		if sprite.frame == 3:
			pass  # Turn hitbox ON
		elif sprite.frame == 6:
			pass  # Turn hitbox OFF

# --- Helper: direction string relative to camera ---
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
