extends CharacterBody3D

@export var speed := 6.0
@export var jump_velocity := 4.0
@export var mouse_sensitivity := 0.002

@onready var camera = $Camera3D
@onready var gun = $Camera3D/Weapon
@onready var bullet_spawn = $Camera3D/Weapon/BulletSpawn

var gravity := 9.8

# Block placement system
var block_count := 0
var current_tool := "gun"  # "gun" or "block_placer"
const BLOCK_SIZE := Vector3(0.64, 0.092, 0.155)  # Size of one block for grid snapping
const PLACEMENT_DISTANCE := 5.0  # Maximum distance for block placement

func _ready():
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
		if current_tool == "gun":
			shoot()
		elif current_tool == "block_placer":
			place_block()
	
	# Tool switching with number keys
	if event is InputEventKey and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.keycode == KEY_1 and event.pressed:
			switch_tool("gun")
		elif event.keycode == KEY_2 and event.pressed:
			switch_tool("block_placer")

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
	print("[Player] Shooting from peer: ", multiplayer.get_unique_id())
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
		print("[Player] Switched to block placer (", block_count, " blocks)")

func pickup_block():
	# Called when player picks up a block
	block_count += 1
	print("[Player] Picked up block! Total blocks: ", block_count)

func place_block():
	# Place a block using raycast from camera
	if block_count <= 0:
		print("[Player] No blocks to place!")
		return
	
	# Raycast from camera to find placement position
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = origin + (-camera.global_transform.basis.z * PLACEMENT_DISTANCE)
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 3  # Same as player collision mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var placement_pos = result.position
		var hit_normal = result.normal
		
		# Snap to grid and handle stacking
		placement_pos = snap_to_grid(placement_pos, hit_normal)
		
		# Check for overlapping blocks before placing
		if not is_position_occupied(placement_pos):
			spawn_placed_block(placement_pos)
			block_count -= 1
			print("[Player] Placed block at ", placement_pos, ". Remaining: ", block_count)
		else:
			print("[Player] Position occupied, cannot place block")
	else:
		print("[Player] No valid surface to place block")

func snap_to_grid(pos: Vector3, normal: Vector3) -> Vector3:
	# Snap position to grid based on block size
	# If placing on top (normal pointing up), stack vertically
	# Otherwise snap to nearest grid position
	
	var snapped_pos = pos
	
	if normal.y > 0.7:  # Placing on top surface
		# Stack on top - align to grid and add block height
		snapped_pos.x = round(pos.x / BLOCK_SIZE.x) * BLOCK_SIZE.x
		snapped_pos.z = round(pos.z / BLOCK_SIZE.z) * BLOCK_SIZE.z
		snapped_pos.y = pos.y + BLOCK_SIZE.y / 2
	else:
		# Placing on side or other surface - snap to grid
		snapped_pos.x = round(pos.x / BLOCK_SIZE.x) * BLOCK_SIZE.x
		snapped_pos.y = round(pos.y / BLOCK_SIZE.y) * BLOCK_SIZE.y
		snapped_pos.z = round(pos.z / BLOCK_SIZE.z) * BLOCK_SIZE.z
	
	return snapped_pos

func is_position_occupied(pos: Vector3) -> bool:
	# Check if there's already a block at this position
	var space_state = get_world_3d().direct_space_state
	
	# Create a small box shape to check for overlaps
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = BoxShape3D.new()
	shape.size = BLOCK_SIZE * 0.9  # Slightly smaller to avoid false positives
	query.shape = shape
	query.transform = Transform3D(Basis(), pos)
	query.collision_mask = 3
	
	var results = space_state.intersect_shape(query)
	
	# Filter out self (player)
	for collision in results:
		if collision.collider != self:
			return true
	
	return false

func spawn_placed_block(pos: Vector3):
	# Spawn a placed block at the given position
	var placed_block_scene = preload("res://Scenes/PlacedBlock.tscn")
	var placed_block = placed_block_scene.instantiate()
	placed_block.global_position = pos
	get_tree().current_scene.add_child(placed_block)
