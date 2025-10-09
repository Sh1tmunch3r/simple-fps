extends Area3D

const SPEED := 30.0
var lifetime := 2.0
var damage := 10.0  # Damage dealt on hit
var shooter_id := 0  # ID of the player who shot this bullet

func _ready():
	# Enable collision
	if has_node("CollisionShape3D"):
		$CollisionShape3D.disabled = false
	
	# Connect body entered signal
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	# Move forward in local space
	translate(Vector3(0, 0, -SPEED * delta))

func _on_body_entered(body):
	print("[Bullet] Hit: ", body.name)
	
	# Check if we hit a player
	if body is CharacterBody3D and body.has_method("take_damage"):
		# Don't damage the shooter
		if body.name != str(shooter_id):
			print("[Bullet] Dealing ", damage, " damage to ", body.name)
			if body.has_method("take_damage"):
				body.take_damage.rpc(damage, shooter_id)
	
	queue_free()
