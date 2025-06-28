extends Node3D


@onready var igcam := $"../InGameCam" as MeshInstance3D

@export var throw_strength: float = 5.0
@export var return_speed: float = 5.0
@export var elasticity: float = 1000.0


var velocity := Vector2.ZERO
var offset := Vector2.ZERO
@onready var shake_timer := $ShakeTimer as Timer


func _ready():
	Global.photo_taken.connect(throw_camera)
	#Global.cam_reached_marker.connect(throw_camera)

func _process(delta):
	if Input.is_key_pressed(KEY_1):
		#_camera_shake(1, 3)
		throw_camera()
	# spring-like motion back to center
	if shake_timer.is_stopped(): return
	var force = -offset * elasticity
	velocity += force * delta 
	velocity *= 0.85  # damping
	offset += velocity * delta 
	self.position = Vector3(offset.x, offset.y, 0)
	

func throw_camera():
	await get_tree().create_timer(0.3)
	shake_timer.start(2)
	var random_dir = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	velocity += random_dir * throw_strength
	await get_tree().create_timer(0.1)
	#random_dir = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	random_dir = Vector2(random_dir.y, random_dir.x)
	velocity += random_dir * throw_strength/3
