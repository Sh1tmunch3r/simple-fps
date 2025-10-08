extends Area3D

const SPEED := 30.0
var lifetime := 2.0

func _ready():
	$CollisionShape3D.disabled = false
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	translate(Vector3(0, 0, -SPEED * delta))

func _on_body_entered(body):
	queue_free()
