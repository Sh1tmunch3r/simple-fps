extends Node3D

@export var player_scene: PackedScene

func _ready():
	print("World.gd loaded!")
	if not multiplayer.has_multiplayer_peer():
		print("No multiplayer peer found.")
		return
	if player_scene:
		print("player_scene is set!")
		var peer_id = multiplayer.get_unique_id()
		var player = player_scene.instantiate()
		player.name = str(peer_id)
		player.set_multiplayer_authority(peer_id)
		player.position = Vector3(randf_range(-5, 5), 1, randf_range(-5, 5))
		add_child(player)
	else:
		print("player_scene is NOT set!")
