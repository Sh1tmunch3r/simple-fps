extends Node3D

# Spawns pickup blocks and loot boxes randomly in the world
# Syncs spawned items across all clients in multiplayer

@export var num_pickup_blocks: int = 10
@export var num_block2_blocks: int = 5  # Also spawn Block2 pickups
@export var num_loot_boxes: int = 3
@export var spawn_radius: float = 20.0  # Radius from world center to spawn items
@export var spawn_height: float = 0.5   # Height above ground to spawn items

var pickup_block_scene = preload("res://Scenes/block.tscn")
var pickup_block2_scene = preload("res://Scenes/Block2.tscn")
var loot_box_scene = preload("res://Scenes/LootBox.tscn")

# Store spawn data for syncing with clients
var spawned_blocks := []
var spawned_block2s := []
var spawned_boxes := []

func _ready():
	print("[WorldSpawner] World spawner ready")
	
	# Only spawn on server or in single player
	if multiplayer.is_server() or not multiplayer.has_multiplayer_peer():
		print("[WorldSpawner] Server - spawning items in world...")
		spawn_pickup_blocks()
		spawn_pickup_block2s()
		spawn_loot_boxes()
	else:
		print("[WorldSpawner] Client - requesting world state from server...")
		# Request world state from server
		request_world_state.rpc_id(1)

@rpc("any_peer", "call_remote")
func request_world_state():
	# Server sends world state to the requesting client
	var sender_id = multiplayer.get_remote_sender_id()
	print("[WorldSpawner] Sending world state to peer ", sender_id)
	sync_world_state.rpc_id(sender_id, spawned_blocks, spawned_block2s, spawned_boxes)

@rpc("authority", "call_local")
func sync_world_state(blocks: Array, block2s: Array, boxes: Array):
	print("[WorldSpawner] Received world state: ", blocks.size(), " blocks, ", block2s.size(), " block2s, ", boxes.size(), " boxes")
	
	# Clear any existing spawned items
	for child in get_children():
		child.queue_free()
	
	# Spawn blocks at synced positions
	for pos in blocks:
		var block = pickup_block_scene.instantiate()
		block.global_position = pos
		add_child(block)
	
	# Spawn block2s at synced positions
	for pos in block2s:
		var block = pickup_block2_scene.instantiate()
		block.global_position = pos
		add_child(block)
	
	# Spawn loot boxes at synced positions
	for pos in boxes:
		var box = loot_box_scene.instantiate()
		box.global_position = pos
		add_child(box)
	
	print("[WorldSpawner] World state synced successfully")

func spawn_pickup_blocks():
	# Spawn pickup blocks at random positions
	for i in range(num_pickup_blocks):
		var spawn_pos = get_random_spawn_position()
		spawned_blocks.append(spawn_pos)
		var block = pickup_block_scene.instantiate()
		block.global_position = spawn_pos
		add_child(block)
		print("[WorldSpawner] Spawned pickup block at ", spawn_pos)

func spawn_pickup_block2s():
	# Spawn Block2 pickups at random positions
	for i in range(num_block2_blocks):
		var spawn_pos = get_random_spawn_position()
		spawned_block2s.append(spawn_pos)
		var block = pickup_block2_scene.instantiate()
		block.global_position = spawn_pos
		add_child(block)
		print("[WorldSpawner] Spawned Block2 pickup at ", spawn_pos)

func spawn_loot_boxes():
	# Spawn loot boxes at random positions
	for i in range(num_loot_boxes):
		var spawn_pos = get_random_spawn_position()
		spawned_boxes.append(spawn_pos)
		var box = loot_box_scene.instantiate()
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
