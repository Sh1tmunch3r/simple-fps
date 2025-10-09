extends CharacterBody3D

@export var speed := 6.0
@export var jump_velocity := 4.0
@export var mouse_sensitivity := 0.002

@onready var camera = $Camera3D
@onready var gun = $Camera3D/Weapon
@onready var bullet_spawn = $Camera3D/Weapon/BulletSpawn

var gravity := 9.8

# Health and PvP system
@export var max_health := 100.0
var health := 100.0
var is_dead := false

# Block placement system
var current_tool := "gun"  # "gun" or "block_placer"
const BLOCK_SIZE := Vector3(0.64, 0.092, 0.155)  # Size of one block for grid snapping
const BLOCK2_SIZE := Vector3(0.5, 0.5, 0.5)  # Size of Block2 for grid snapping
const PLACEMENT_DISTANCE := 5.0  # Maximum distance for block placement
const REMOVAL_DISTANCE := 5.0  # Maximum distance for block removal

# Inventory system - supports multiple item types
var inventory := {
	"blocks": 0,
	"block2": 0,
	"red_blocks": 0,
	"blue_blocks": 0,
	"items": 0,
	"guns": 0
}

# Current block rotation (in 90-degree increments)
var block_rotation := 0  # 0, 90, 180, 270
var current_block_type := "blocks"  # "blocks" or "block2"

# Gun mechanics
var is_aiming := false
var ammo := 30
var max_ammo := 30
var reserve_ammo := 90
var is_reloading := false
const RELOAD_TIME := 2.0

func _ready():
	# Add to players group for UI to find
	add_to_group("players")
	
	print("[Player] Ready! Peer ID: ", name, ", Authority: ", is_multiplayer_authority())
	if is_multiplayer_authority():
		print("[Player] This is the local player, capturing mouse")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		print("[Player] This is a remote player")
		camera.current = false

func _input(event):
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if current_tool == "gun" and not is_reloading:
			shoot()
		elif current_tool == "block_placer":
			place_block()
	
	# ADS (Aim Down Sights) - hold right click
	if event.is_action_pressed("aim") and current_tool == "gun" and not is_reloading:
		is_aiming = true
		apply_ads()
	elif event.is_action_released("aim"):
		is_aiming = false
		remove_ads()
	
	# Tool switching with number keys
	if event is InputEventKey and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.keycode == KEY_1 and event.pressed:
			switch_tool("gun")
		elif event.keycode == KEY_2 and event.pressed:
			switch_tool("block_placer")
		# Reload gun
		elif event.keycode == KEY_R and event.pressed and current_tool == "gun":
			reload_gun()
		# Block rotation
		elif event.keycode == KEY_R and event.pressed and current_tool == "block_placer":
			rotate_block()
		# Block removal
		elif event.keycode == KEY_E and event.pressed and current_tool == "block_placer":
			remove_block()
		# Interact with objects (like loot boxes)
		elif event.keycode == KEY_F and event.pressed:
			interact_with_object()
		# Switch block type when in block placer mode
		elif event.keycode == KEY_Q and event.pressed and current_tool == "block_placer":
			switch_block_type()

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

func shoot():
	if is_dead or is_reloading:
		return
	
	if ammo <= 0:
		print("[Player] Out of ammo! Press R to reload")
		return
	
	ammo -= 1
	print("[Player] Shooting from peer: ", multiplayer.get_unique_id(), " | Ammo: ", ammo, "/", max_ammo)
	
	# Raycast to check for hit
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin + (-camera.global_transform.basis.z * 100.0)
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.collision_mask = 3
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		var hit_object = result.collider
		# Check if we hit another player
		if hit_object.has_method("take_damage"):
			var damage = 20.0 if is_aiming else 15.0  # More damage when aiming
			print("[Player] Hit player: ", hit_object.name, " for ", damage, " damage")
			hit_object.take_damage.rpc(damage, multiplayer.get_unique_id())
	
	# Spawn visual bullet for feedback
	var bullet_scene = preload("res://Scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_transform = bullet_spawn.global_transform
	get_tree().current_scene.add_child(bullet)

func switch_tool(tool: String):
	# Switch between gun and block placer
	current_tool = tool
	if tool == "gun":
		gun.visible = true
		print("[Player] Switched to gun")
	elif tool == "block_placer":
		gun.visible = false
		print("[Player] Switched to block placer (", inventory["blocks"], " blocks)")

func pickup_block(block_type: String = "blocks"):
	# Called when player picks up a block or item
	if inventory.has(block_type):
		inventory[block_type] += 1
		print("[Player] Picked up ", block_type, "! Total: ", inventory[block_type])
		update_inventory_ui()
	else:
		print("[Player] Unknown item type: ", block_type)

func place_block():
	# Place a block using raycast from camera
	if inventory[current_block_type] <= 0:
		print("[Player] No ", current_block_type, " to place!")
		return
	
	# Raycast from camera to find placement position
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin + (-camera.global_transform.basis.z * PLACEMENT_DISTANCE)
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.collision_mask = 3  # Same as player collision mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var placement_pos = result.position
		var hit_normal = result.normal
		
		# Snap to grid and handle stacking based on block type
		placement_pos = snap_to_grid(placement_pos, hit_normal)
		
		# Check for overlapping blocks before placing
		if not is_position_occupied(placement_pos):
			# Sync block placement across network
			spawn_placed_block_rpc.rpc(placement_pos, block_rotation, current_block_type)
			inventory[current_block_type] -= 1
			print("[Player] Placed ", current_block_type, " at ", placement_pos, ". Remaining: ", inventory[current_block_type])
			update_inventory_ui()
		else:
			print("[Player] Position occupied, cannot place block")
	else:
		print("[Player] No valid surface to place block")

func snap_to_grid(pos: Vector3, normal: Vector3) -> Vector3:
	# Snap position to grid based on block size
	# If placing on top (normal pointing up), stack vertically
	# Otherwise snap to nearest grid position
	
	var block_size = BLOCK2_SIZE if current_block_type == "block2" else BLOCK_SIZE
	var snapped_pos = pos
	
	if normal.y > 0.7:  # Placing on top surface
		# Stack on top - align to grid and add block height
		snapped_pos.x = round(pos.x / block_size.x) * block_size.x
		snapped_pos.z = round(pos.z / block_size.z) * block_size.z
		snapped_pos.y = pos.y + block_size.y / 2
	else:
		# Placing on side or other surface - snap to grid
		snapped_pos.x = round(pos.x / block_size.x) * block_size.x
		snapped_pos.y = round(pos.y / block_size.y) * block_size.y
		snapped_pos.z = round(pos.z / block_size.z) * block_size.z
	
	return snapped_pos

func is_position_occupied(pos: Vector3) -> bool:
	# Check if there's already a block at this position
	var space_state = get_world_3d().direct_space_state
	
	# Create a small box shape to check for overlaps
	var block_size = BLOCK2_SIZE if current_block_type == "block2" else BLOCK_SIZE
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = BoxShape3D.new()
	shape.size = block_size * 0.9  # Slightly smaller to avoid false positives
	query.shape = shape
	query.transform = Transform3D(Basis(), pos)
	query.collision_mask = 3
	
	var results = space_state.intersect_shape(query)
	
	# Filter out self (player)
	for collision in results:
		if collision.collider != self:
			return true
	
	return false

@rpc("any_peer", "call_local")
func spawn_placed_block_rpc(pos: Vector3, rotation_angle: int = 0, block_type: String = "blocks"):
	# Spawn a placed block at the given position with rotation
	# This is synced across all clients via RPC
	var placed_block_scene
	if block_type == "block2":
		placed_block_scene = preload("res://Scenes/PlacedBlock2.tscn")
	else:
		placed_block_scene = preload("res://Scenes/PlacedBlock.tscn")
	
	var placed_block = placed_block_scene.instantiate()
	placed_block.global_position = pos
	# Apply rotation around Y axis
	placed_block.rotation_degrees.y = rotation_angle
	get_tree().current_scene.add_child(placed_block)
	print("[Player] Spawned ", block_type, " at ", pos, " for all clients")

func remove_block():
	# Remove a block that the player is looking at
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin + (-camera.global_transform.basis.z * REMOVAL_DISTANCE)
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.collision_mask = 3  # Same as player collision mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result.collider
		# Check if the hit object is a placed block (StaticBody3D with specific structure)
		if hit_object is StaticBody3D and hit_object.get_parent() == get_tree().current_scene:
			print("[Player] Removing block at ", hit_object.global_position)
			hit_object.queue_free()
			# Return block to inventory
			inventory["blocks"] += 1
			update_inventory_ui()
			print("[Player] Block removed! Total blocks: ", inventory["blocks"])
		else:
			print("[Player] Cannot remove this object")
	else:
		print("[Player] No block to remove")

func rotate_block():
	# Rotate the block placement preview by 90 degrees
	block_rotation = (block_rotation + 90) % 360
	print("[Player] Block rotation: ", block_rotation, " degrees")

func update_inventory_ui():
	# Update the inventory UI - will be connected to UI system
	# This will be called whenever inventory changes
	pass

func interact_with_object():
	# Interact with objects in the world (like loot boxes)
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin + (-camera.global_transform.basis.z * PLACEMENT_DISTANCE)
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.collision_mask = 3
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result.collider
		# Check if the object has an interact method
		if hit_object.has_method("interact"):
			print("[Player] Interacting with ", hit_object.name)
			hit_object.interact(self)
		else:
			print("[Player] Cannot interact with this object")

# PvP Health and Damage System
@rpc("any_peer", "call_local")
func take_damage(damage: float, attacker_id: int):
	if is_dead:
		return
	
	health -= damage
	print("[Player] Took ", damage, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		die(attacker_id)

func die(killer_id: int):
	is_dead = true
	health = 0
	print("[Player] Died! Killed by peer: ", killer_id)
	
	# Hide player model and disable controls
	visible = false
	
	# Respawn after delay
	await get_tree().create_timer(3.0).timeout
	respawn()

func respawn():
	is_dead = false
	health = max_health
	ammo = max_ammo
	visible = true
	
	# Random respawn position
	global_position = Vector3(randf_range(-10, 10), 2, randf_range(-10, 10))
	
	print("[Player] Respawned at ", global_position, " with full health")

# Gun Mechanics
func reload_gun():
	if is_reloading or ammo >= max_ammo:
		print("[Player] Cannot reload right now")
		return
	
	if reserve_ammo <= 0:
		print("[Player] No reserve ammo!")
		return
	
	is_reloading = true
	print("[Player] Reloading... (", RELOAD_TIME, "s)")
	
	await get_tree().create_timer(RELOAD_TIME).timeout
	
	var ammo_needed = max_ammo - ammo
	var ammo_to_reload = min(ammo_needed, reserve_ammo)
	
	ammo += ammo_to_reload
	reserve_ammo -= ammo_to_reload
	
	is_reloading = false
	print("[Player] Reload complete! Ammo: ", ammo, "/", max_ammo, " | Reserve: ", reserve_ammo)

func apply_ads():
	# Apply ADS effect - zoom in camera FOV
	if camera:
		camera.fov = 50  # Zoomed in FOV (default is usually 70-75)
		print("[Player] Aiming down sights")

func remove_ads():
	# Remove ADS effect - restore normal FOV
	if camera:
		camera.fov = 70  # Normal FOV
		print("[Player] Stopped aiming")

func switch_block_type():
	# Switch between block types
	if current_block_type == "blocks":
		current_block_type = "block2"
		print("[Player] Switched to Block2 (", inventory["block2"], " available)")
	else:
		current_block_type = "blocks"
		print("[Player] Switched to regular blocks (", inventory["blocks"], " available)")
