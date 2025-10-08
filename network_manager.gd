extends Node

const DEFAULT_PORT := 12345
const MAX_PLAYERS := 8

signal server_started
signal connected_to_server
signal connection_failed

func host_game():
	print("[NetworkManager] Creating server on port ", DEFAULT_PORT)
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if err != OK:
		print("[NetworkManager] Failed to create server: ", err)
		emit_signal("connection_failed")
		return
	multiplayer.multiplayer_peer = peer
	print("[NetworkManager] Server created successfully, peer ID: ", multiplayer.get_unique_id())
	emit_signal("server_started")

func join_game(ip: String):
	print("[NetworkManager] Connecting to ", ip, ":", DEFAULT_PORT)
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, DEFAULT_PORT)
	if err != OK:
		print("[NetworkManager] Failed to create client: ", err)
		emit_signal("connection_failed")
		return
	multiplayer.multiplayer_peer = peer
	print("[NetworkManager] Client created, waiting for connection...")

func _ready():
	print("[NetworkManager] Ready")
	multiplayer.connected_to_server.connect(func(): 
		print("[NetworkManager] Connected to server!")
		emit_signal("connected_to_server")
	)
	multiplayer.connection_failed.connect(func(): 
		print("[NetworkManager] Connection failed!")
		emit_signal("connection_failed")
	)
