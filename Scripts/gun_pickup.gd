extends Area3D

# Script for gun pickups that can be collected by the player
# When player enters the pickup area, they get extra ammo

signal picked_up

@export var ammo_amount: int = 30  # Amount of ammo to give
@export var reserve_ammo_amount: int = 60  # Reserve ammo to give

func _ready():
	# Connect the body_entered signal to detect when player picks up the gun
	body_entered.connect(_on_body_entered)
	print("[GunPickup] Gun pickup ready at position: ", global_position)

func _on_body_entered(body):
	# Check if the body that entered is the player (CharacterBody3D)
	if body is CharacterBody3D and body.has_method("pickup_gun"):
		print("[GunPickup] Player picked up gun ammo!")
		body.pickup_gun(ammo_amount, reserve_ammo_amount)
		picked_up.emit()
		# Remove the gun from the scene after pickup
		queue_free()
