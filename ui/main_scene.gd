extends Node

@onready var world_container = $WorldContainer
@onready var player = $Player

func _ready():
	# 1. Hand the references over to the GameManager Autoload
	GameManager.world_container = world_container
	GameManager.player = player
	
	# 2. Pause the player physics so they don't fall into the void before hitting Start
	if player:
		player.set_physics_process(false)
