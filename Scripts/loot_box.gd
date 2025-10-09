extends StaticBody3D

# Lootable box that can be interacted with to gain items
# Can only be looted once per box

@export var loot_blocks: int = 5  # Number of blocks to give
@export var loot_items: int = 2   # Number of items to give
@export var can_loot: bool = true # Whether this box has been looted

var material_looted: StandardMaterial3D
var material_unllooted: StandardMaterial3D

func _ready():
	print("[LootBox] Loot box ready at position: ", global_position)
	
	# Create materials for looted/unlooted states
	material_unllooted = StandardMaterial3D.new()
	material_unllooted.albedo_color = Color(0.8, 0.6, 0.2)  # Brown/gold color
	
	material_looted = StandardMaterial3D.new()
	material_looted.albedo_color = Color(0.4, 0.4, 0.4)  # Gray color
	
	update_appearance()

func interact(player):
	# Called when player presses F key while looking at the box
	if can_loot:
		print("[LootBox] Player looting box!")
		# Give loot to player
		if player.has_method("pickup_block"):
			for i in range(loot_blocks):
				player.pickup_block("blocks")
			for i in range(loot_items):
				player.pickup_block("items")
		
		# Mark as looted
		can_loot = false
		update_appearance()
		print("[LootBox] Box looted! Gave ", loot_blocks, " blocks and ", loot_items, " items")
	else:
		print("[LootBox] This box has already been looted")

func update_appearance():
	# Update the box appearance based on looted state
	# This assumes the box has a MeshInstance3D child
	for child in get_children():
		if child is MeshInstance3D:
			if can_loot:
				child.material_override = material_unllooted
			else:
				child.material_override = material_looted
