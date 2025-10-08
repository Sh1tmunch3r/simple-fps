extends Node

const DEFAULT_PORT := 12345
const MAX_PLAYERS := 8

signal server_started
signal connected_to_server
signal connection_failed

func host_game():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if err != OK:
		emit_signal("connection_failed")
		return
	multiplayer.multiplayer_peer = peer
	emit_signal("server_started")

func join_game(ip: String):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, DEFAULT_PORT)
	if err != OK:
		emit_signal("connection_failed")
		return
	multiplayer.multiplayer_peer = peer

func _ready():
	multiplayer.connected_to_server.connect(emit_signal.bind("connected_to_server"))
	multiplayer.connection_failed.connect(emit_signal.bind("connection_failed"))
