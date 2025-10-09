extends Area3D

# Script for pickup blocks that can be collected by the player
# When player enters the pickup area, the block can be collected

signal picked_up

@export var block_type: String = "blocks"  # Type of block: "blocks", "red_blocks", "blue_blocks", "items"

func _ready():
	# Connect the body_entered signal to detect when player picks up the block
	body_entered.connect(_on_body_entered)
	print("[Block] Pickup block ready (type: ", block_type, ")")

func _on_body_entered(body):
	# Check if the body that entered is the player (CharacterBody3D)
	if body is CharacterBody3D and body.has_method("pickup_block"):
		print("[Block] Player picked up ", block_type, "!")
		body.pickup_block(block_type)
		picked_up.emit()
		# Remove the block from the scene after pickup
		queue_free()
