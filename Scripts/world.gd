extends Node3D

@export var player_scene: PackedScene

func _ready():
	print("[World] World.gd loaded!")
	
	if not multiplayer.has_multiplayer_peer():
		print("[World] ERROR: No multiplayer peer found.")
		return
	
	print("[World] Multiplayer peer found. Is server: ", multiplayer.is_server())
	
	if not player_scene:
		print("[World] ERROR: player_scene is NOT set!")
		return
	
	print("[World] player_scene is set, spawning player...")
	spawn_player(multiplayer.get_unique_id())
	
	# Connect to peer connected signal to spawn players for new clients
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		print("[World] Server setup complete, listening for peer connections")

func spawn_player(peer_id: int):
	print("[World] Spawning player for peer: ", peer_id)
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	var spawn_pos = Vector3(randf_range(-5, 5), 1, randf_range(-5, 5))
	player.position = spawn_pos
	print("[World] Player spawn position: ", spawn_pos)
	add_child(player)
	print("[World] Player added to scene tree")

func _on_peer_connected(peer_id: int):
	print("[World] Peer connected: ", peer_id, " - spawning their player")
	spawn_player(peer_id)
