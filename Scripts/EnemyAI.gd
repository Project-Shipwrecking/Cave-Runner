extends Node3D

@export var curve : Curve
var past_body : CharacterBody3D 
var prev_dir: Vector2 = Vector2(0,0)
var current_movement : MovementClass
signal target_reached 

func random_dir() -> Vector2:
	var rand := Vector2(randfn(prev_dir.x,.5),randfn(prev_dir.x,.5))
	rand += prev_dir
	return Vector2(rand.x, rand.y).normalized()
		
	
func _process(delta: float) -> void:
	if current_movement.distance > .1 and global_position.distance_to(current_movement.start) > current_movement.distance:
		pathfind_end()
		target_reached.emit()

func pathfind(move : MovementClass, body : CharacterBody3D) -> void:
	past_body = body
	current_movement = move
	prev_dir = current_movement.direction
	current_movement.start = body.global_position
	body.velocity.x = current_movement.direction.x * current_movement.speed
	body.velocity.z = current_movement.direction.y * current_movement.speed
	body.move_and_slide()
	Global.monster_moving = false
	
	
	
func pathfind_end() -> void:
	past_body.velocity = Vector3.ZERO
	current_movement = MovementClass.new()
