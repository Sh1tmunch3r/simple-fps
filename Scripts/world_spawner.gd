extends Node3D

# Spawns pickup blocks and loot boxes randomly in the world
# Only runs on the server in multiplayer

@export var num_pickup_blocks: int = 10
@export var num_loot_boxes: int = 3
@export var spawn_radius: float = 20.0  # Radius from world center to spawn items
@export var spawn_height: float = 0.5   # Height above ground to spawn items

var pickup_block_scene = preload("res://Scenes/block.tscn")
var loot_box_scene = preload("res://Scenes/LootBox.tscn")

func _ready():
	print("[WorldSpawner] World spawner ready")
	
	# Only spawn on server or in single player
	if multiplayer.is_server() or not multiplayer.has_multiplayer_peer():
		print("[WorldSpawner] Spawning items in world...")
		spawn_pickup_blocks()
		spawn_loot_boxes()
	else:
		print("[WorldSpawner] Client - not spawning items")

func spawn_pickup_blocks():
	# Spawn pickup blocks at random positions
	for i in range(num_pickup_blocks):
		var block = pickup_block_scene.instantiate()
		var spawn_pos = get_random_spawn_position()
		block.global_position = spawn_pos
		add_child(block)
		print("[WorldSpawner] Spawned pickup block at ", spawn_pos)

func spawn_loot_boxes():
	# Spawn loot boxes at random positions
	for i in range(num_loot_boxes):
		var box = loot_box_scene.instantiate()
		var spawn_pos = get_random_spawn_position()
		box.global_position = spawn_pos
		add_child(box)
		print("[WorldSpawner] Spawned loot box at ", spawn_pos)

func get_random_spawn_position() -> Vector3:
	# Get a random position within the spawn radius
	var angle = randf() * TAU  # Random angle in radians
	var distance = randf() * spawn_radius
	var x = cos(angle) * distance
	var z = sin(angle) * distance
	return Vector3(x, spawn_height, z)
