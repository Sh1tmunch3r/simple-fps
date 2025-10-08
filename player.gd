extends CharacterBody3D

@export var speed := 6.0
@export var jump_velocity := 4.0
@export var mouse_sensitivity := 0.002

@onready var camera = $Camera3D
@onready var gun = $Camera3D/Weapon
@onready var bullet_spawn = $Camera3D/Weapon/BulletSpawn

var gravity := 9.8

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
		shoot()

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
	var bullet_scene = preload("res://Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_transform = bullet_spawn.global_transform
	get_tree().current_scene.add_child(bullet)
