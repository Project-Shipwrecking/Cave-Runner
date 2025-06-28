class_name Player extends CharacterBody3D

@export_category("Player")
var speed: float = 2 # m/s
var sprint_speed : float= 5
var sprint_usage : float = 30
var sprint_recovery : float = 10
@export_range(10, 400, 1) var acceleration: float = 50 # m/s^2
	
@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m

@export_category("Camera")
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 5
@export_range(0.1, 10, 0.05,"or_greater") var bob_freq: float = 3.0
@export_range(0.0, 0.5, 0.01,"or_greater") var bob_amp: float = .03
var head_bob_time := 0.0

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var head: Node3D = $Head
@onready var camera: Camera3D = get_viewport().get_camera_3d()
var ui : UI
var focus_cam : bool = false

func _ready() -> void:
	capture_mouse()
	ui = get_node("/root/" + get_tree().current_scene.name + "/CanvasLayer/UI") as UI
	
	Global.focus_cam.connect(update_cam_state)

func update_cam_state(is_taking:bool):
	#if is_taking == false: print_debug("Finsihed photo")
	focus_cam = is_taking
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()

func _physics_process(delta: float) -> void:
	#if mouse_captured: _handle_joypad_camera_rotation(delta)
	var move_speed = speed
	if Input.is_action_pressed("sprint") and ui.sprint_value > 0 and ui.sprint_timer.is_stopped():
		move_speed = sprint_speed
		ui.sprint_value -= sprint_usage * delta
	elif is_zero_approx(ui.sprint_value) and ui.sprint_timer.is_stopped():
		ui.sprint_timer.start()
	elif ui.sprint_timer.is_stopped():
		ui.sprint_value += sprint_recovery * delta
	
	var walk = _walk(delta, move_speed)
	if focus_cam:
		walk *= 0.8
	velocity = walk + _gravity(delta) + _jump(delta)
	move_and_slide()
	
	# Bob head:
	if not focus_cam: 
		head_bob_time += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = bob_head(head_bob_time)
	
	
func bob_head(bob_time: float):
	var bob_pos = Vector3.ZERO
	bob_pos.y = sin(bob_time * bob_freq) * bob_amp
	bob_pos.x = cos(bob_time * bob_freq / 2) * bob_amp
	return bob_pos

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	head.rotation.y -= look_dir.x * camera_sens * sens_mod
	head.rotation.x = clamp(head.rotation.x - look_dir.y * camera_sens * sens_mod, -1, 1)

#func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	#var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	#if joypad_dir.length() > 0:
		#look_dir += joypad_dir * delta
		#_rotate_camera(sens_mod)
		#look_dir = Vector2.ZERO

func _walk(delta: float, sped:float) -> Vector3:
	move_dir = Input.get_vector("left", "right", "forward", "backward")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * sped, acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
