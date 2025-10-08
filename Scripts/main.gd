extends Control

@onready var network_manager = $"/root/network_manager"
@onready var ip_input = $IPInput
@onready var host_btn = $HostButton
@onready var join_btn = $JoinButton
@onready var status_lbl = $StatusLabel

func _ready():
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	network_manager.server_started.connect(_on_server_started)
	network_manager.connected_to_server.connect(_on_connected_to_server)
	network_manager.connection_failed.connect(_on_connection_failed)

func _on_host_pressed():
	print("[Main] Host button pressed")
	status_lbl.text = "Starting server..."
	network_manager.host_game()

func _on_join_pressed():
	print("[Main] Join button pressed, IP: ", ip_input.text)
	status_lbl.text = "Connecting..."
	network_manager.join_game(ip_input.text)

func _on_server_started():
	status_lbl.text = "Server started! Loading game..."
	print("[Main] Server started, loading World scene...")
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_connected_to_server():
	status_lbl.text = "Connected! Loading game..."
	print("[Main] Connected to server, loading World scene...")
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_connection_failed():
	status_lbl.text = "Connection failed. Try again."
