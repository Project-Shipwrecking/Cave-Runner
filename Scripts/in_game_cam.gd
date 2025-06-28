class_name InGameCam extends MeshInstance3D

@onready var cam : Camera3D = $SubViewport/Camera3D
@onready var marker := $CamPos as Marker3D
@onready var look_marker := $"../LookAt" as Marker3D
@onready var portal_shader: Shader = preload("res://Shaders/in_game_cam.gdshader")
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

func _set_portal_material():
	viewport = $SubViewport
	#viewport.
	#viewport = SubViewport.new()
	#viewport.size = get_window().size 
	#viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	#viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	#add_child(viewport)
	var viewport_texture = viewport.get_texture()
	
	#cam = Camera3D.new()
	#viewport.add_child(cam)
	
	var material = ShaderMaterial.new()
	material.shader = portal_shader
	#material.set_shader_parameter("albedo", viewport.get_texture())
	material.set_shader_parameter("albedo", viewport_texture)
	#self.material_override = material
	set_surface_override_material(0, material)

var original_transform 

func start_interpolation():
	taking_photo.emit(true)
	
	if current_state != State.IDLE:
		return # Don't start if already interpolating
	var target_transform = $"../IGCPlace".transform
	var interpolation_duration = .2
	var delay_at_marker = .5
	original_transform = transform
	print("interpolating?")
	current_state = State.MOVING_TO_MARKER
	tween = get_tree().create_tween() # Create a new tween for each sequence
	tween.tween_property(self, "transform", target_transform, interpolation_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT) # Smooth start/end

	# Chain the next steps
	tween.tween_interval(delay_at_marker) # Wait at the marker
	tween.tween_callback(Callable(self, "_on_reached_marker")) # Call function when interval finishes
	tween.tween_property(self, "transform", original_transform, interpolation_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Connect a signal to know when the whole tween sequence finishes
	tween.finished.connect(_on_tween_finished)

func _on_reached_marker():
	current_state = State.AT_MARKER
	print("Reached marker!")

func _on_tween_finished():
	current_state = State.IDLE
	print("Returned to original!")
	tween = null # Clear the tween reference
	taking_photo.emit(false)



func _process(_delta):
	if current_state == State.IDLE:
		self.look_at(look_marker.global_position, Vector3.LEFT)
		self.look_at(look_marker.global_position, Vector3.UP)
	if Input.is_action_just_pressed("left_click"):
		start_interpolation()
	cam.global_transform = marker.global_transform
	
