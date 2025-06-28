class_name InGameCam extends MeshInstance3D

@onready var cam : Camera3D = $SubViewport/Camera3D
@onready var marker := $CamPos as Marker3D
@onready var look_marker := $"../LookAt" as Marker3D
@onready var portal_shader: Shader = preload("res://Shaders/in_game_cam.gdshader")
@onready var flash := $SpotLight3D as SpotLight3D

var viewport 
var current_state = State.IDLE
var tween : Tween
signal taking_photo(is_taking:bool)
enum State {
	IDLE,
	MOVING_TO_MARKER,
	AT_MARKER,
	RETURNING_TO_ORIGINAL
}

func _ready():
	_set_portal_material()
	flash.light_energy = 0

func _set_portal_material():
	viewport = $SubViewport
	var viewport_texture = viewport.get_texture()
	
	var material = ShaderMaterial.new()
	material.shader = portal_shader
	material.set_shader_parameter("albedo", viewport_texture)
	set_surface_override_material(0, material)

var original_transform 

func start_interpolation():
	if current_state != State.IDLE or self.visible == false:
		return # Don't start if already interpolating
		
	Global.taking_photo.emit(true)
	
	var target_transform = $"../IGCPlace".transform
	var interpolation_duration = .2
	var delay_at_marker = .7
	original_transform = transform
	print("interpolating?")
	current_state = State.MOVING_TO_MARKER
	
	tween = get_tree().create_tween() # Create a new tween for each sequence
	tween.set_parallel(true)
	tween.tween_property(self, "transform", target_transform, interpolation_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT) # Smooth start/end
	tween.tween_property(flash, "light_energy", 1.5, 0.1)
	
	# Chain the next steps (ignore parallel)
	tween.chain()
	tween.tween_property(flash, "light_energy", 0, .5)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.chain()
	tween.tween_interval(delay_at_marker-.5) # Wait at the marker
	tween.tween_callback(Callable(self, "_on_reached_marker")) # Call function when interval finishes
	tween.tween_property(self, "transform", original_transform, interpolation_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Connect a signal to know when the whole tween sequence finishes
	tween.finished.connect(_on_tween_finished)

func _on_reached_marker():
	current_state = State.AT_MARKER
	Global.cam_reached_marker.emit()
	

func _on_tween_finished():
	current_state = State.IDLE
	print("Returned to original!")
	tween = null # Clear the tween reference
	Global.taking_photo.emit(false)



func _process(_delta):
	if current_state == State.IDLE:
		self.look_at(look_marker.global_position, Vector3.LEFT)
		self.look_at(look_marker.global_position, Vector3.UP)
	if Input.is_action_just_pressed("left_click"):
		start_interpolation()
	cam.global_transform = marker.global_transform
	
