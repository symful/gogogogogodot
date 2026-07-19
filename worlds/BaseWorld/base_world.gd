extends Node3D
class_name BaseWorld

enum WorldMode { FREE_ROAM, ROOM_ROAM, BATTLE }

@export var location_name: String = "Unknown Region"
@export var current_mode: WorldMode = WorldMode.FREE_ROAM

func _ready():
	# When the level loads, we find the camera and tell it what mode to use
	var camera = get_viewport().get_camera_3d()
	if camera and camera.has_method("set_camera_mode"):
		camera.set_camera_mode(current_mode)
