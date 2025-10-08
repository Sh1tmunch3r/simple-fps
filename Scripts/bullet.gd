extends Area3D

const SPEED := 30.0
var lifetime := 2.0

func _ready():
	# Enable collision
	if has_node("CollisionShape3D"):
		$CollisionShape3D.disabled = false
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	# Move forward in local space
	translate(Vector3(0, 0, -SPEED * delta))

func _on_body_entered(body):
	print("[Bullet] Hit: ", body.name)
	queue_free()
