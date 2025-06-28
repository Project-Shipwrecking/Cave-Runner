extends Node3D


@onready var igcam := $"../InGameCam" as MeshInstance3D

@export var throw_strength: float = 3.0
@export var return_speed: float = 5.0
@export var elasticity: float = 1000.0


var velocity := Vector2.ZERO
var offset := Vector2.ZERO



func _process(delta):
	if Input.is_key_pressed(KEY_1):
		#_camera_shake(1, 3)
		throw_camera()
	# spring-like motion back to center
	var force = -offset * elasticity
	velocity += force * delta 
	velocity *= 0.9  # damping
	offset += velocity * delta 
	self.position = Vector3(offset.x, offset.y, 0)
	

func throw_camera():
	var random_dir = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	velocity += random_dir * throw_strength
	await get_tree().create_timer(0.1)
	random_dir = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	velocity += random_dir * throw_strength/3
	
#func _process(delta: float) -> void:
	## test input
		#_CameraShake3D._custom_shake(3, 0.05)
#
	#elif Input.is_key_pressed(KEY_2):
		#_CameraShake3D._custom_shake(2, 0.1)
#
	#elif Input.is_key_pressed(KEY_3):
		#_CameraShake3D._custom_shake(1, 0.25)
		#
	#elif Input.is_key_pressed(KEY_4):
		#_CameraShake3D._custom_shake(0.5, 0.5)
	
		

var initial_transform
var tween
func _camera_shake(time:float, strength:float):
	initial_transform = self.position 
	
	tween = get_tree().create_tween()
	var offset := Vector3(randf_range(-strength, strength), randf_range(-strength, strength), 0.0)
	var offset2 := Vector3(randf_range(-strength/2, strength/2), randf_range(-strength/2, strength/2), 0.0)
	tween.set_ease(Tween.EASE_OUT)
	#tween.set_process_mode()
	tween.set_loops(1)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_parallel(true)
	tween.tween_callback(_reset_pos)
	tween.tween_property(self, "position", offset, time)
	tween.tween_property(self, "position", Vector3(offset.y, offset.y, 0), time)
	
	#tween.tween_callback(_reset_pos)

func _reset_pos():
	tween.stop()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_parallel(false)
	tween.tween_property(self, "position", initial_transform, 1)
	self.position = initial_transform
