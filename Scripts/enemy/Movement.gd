extends Node3D
@onready var body : CharacterBody3D = $".."

func move(movement: MovementClass):
	# Create rotation transform from body's current rotation
	var rotation_transform := Transform3D().rotated(Vector3.UP, 2 * body.rotation.y)

	# Apply rotation to input direction
	var direction: Vector3 = (rotation_transform.basis * Vector3(movement.direction.normalized().x, 0, movement.direction.normalized().y)).normalized()

	if direction != Vector3.ZERO:
		body.velocity.x = direction.x * movement.speed
		body.velocity.z = direction.z * movement.speed
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, movement.speed)
		body.velocity.z = move_toward(body.velocity.z, 0, movement.speed)
	body.move_and_slide()
