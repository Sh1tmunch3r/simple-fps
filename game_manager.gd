extends Node

@export var player_scene: PackedScene

func spawn_player(peer_id := 1):
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	# Random starting position
	player.position = Vector3(randf_range(-5, 5), 1, randf_range(-5, 5))
	get_tree().current_scene.add_child(player)
