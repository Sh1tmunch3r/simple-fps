extends Control

# Inventory UI - displays player's inventory in a simple overlay

@onready var inventory_label = $InventoryLabel
@onready var interaction_label = $InteractionLabel

var player: CharacterBody3D = null

func _ready():
	# Find the local player
	await get_tree().process_frame  # Wait for player to be spawned
	find_player()
	
	# Hide interaction label initially
	if interaction_label:
		interaction_label.visible = false

func find_player():
	# Find the local player (the one with multiplayer authority)
	for node in get_tree().get_nodes_in_group("players"):
		if node.is_multiplayer_authority():
			player = node
			print("[InventoryUI] Found local player: ", player.name)
			update_inventory_display()
			return
	
	# If not found, try again after a short delay
	await get_tree().create_timer(0.5).timeout
	find_player()

func _process(_delta):
	if player:
		update_inventory_display()

func update_inventory_display():
	if not player or not inventory_label:
		return
	
	var inv = player.inventory
	var text = "=== INVENTORY ===\n"
	text += "Health: " + str(int(player.health)) + "/" + str(int(player.max_health)) + "\n"
	text += "Blocks: " + str(inv["blocks"]) + "\n"
	text += "Block2: " + str(inv["block2"]) + "\n"
	text += "Items: " + str(inv["items"]) + "\n"
	text += "\nTool: " + player.current_tool.to_upper()
	
	if player.current_tool == "gun":
		if player.is_reloading:
			text += "\nAmmo: RELOADING..."
		else:
			text += "\nAmmo: " + str(player.ammo) + "/" + str(player.max_ammo)
		text += "\nReserve: " + str(player.reserve_ammo)
		text += "\n" + ("ADS: ON" if player.is_aiming else "ADS: OFF")
	elif player.current_tool == "block_placer":
		text += "\nRotation: " + str(player.block_rotation) + "°"
		text += "\nBlock Type: " + player.current_block_type.to_upper()
	
	inventory_label.text = text

func show_interaction_prompt(message: String):
	if interaction_label:
		interaction_label.text = message
		interaction_label.visible = true

func hide_interaction_prompt():
	if interaction_label:
		interaction_label.visible = false
