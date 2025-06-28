class_name InGameCam extends MeshInstance3D

@onready var cam : Camera3D = $SubViewport/Camera3D
@onready var marker := %Camera 
@onready var look_marker := $"../LookAt" as Marker3D
#@onready var portal_shader: Shader = preload("res://Shaders/in_game_cam_test.gdshader")
@onready var portal_shader: Shader = preload("res://Shaders/in_game_cam.gdshader")
@onready var flash := $SpotLight3D as SpotLight3D

var viewport : SubViewport
var current_state = State.IDLE
var tween : Tween
var is_taking_photo = false
enum State {
	IDLE,
	MOVING_TO_MARKER,
	AT_MARKER,
	RETURNING_TO_ORIGINAL
}

var original_transform 

func _ready():
	_set_portal_material()
	flash.light_energy = 0
	original_transform = transform

func _set_portal_material():
	viewport = $SubViewport
	#viewport = get_viewport()
	var viewport_texture = viewport.get_texture()
	viewport.size = get_viewport().size
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	var material = ShaderMaterial.new()
	material.shader = portal_shader
	#material.set_shader_parameter("face_size", get_viewport().size)
	
	material.set_shader_parameter("camera_inv_transform", cam.global_transform.affine_inverse())
	material.set_shader_parameter("model_matrix", global_transform)
	
	material.set_shader_parameter("albedo", viewport_texture)
	set_surface_override_material(0, material)


func hold_cam(val:bool):
	if self.visible == false:
		return # Don't start if already interpolating
	var interpolation_duration = .2
	var delay_at_marker = .7
	if val == true:
		if current_state != State.IDLE: return
		var target_transform = $"../IGCPlace".transform
		Global.focus_cam.emit(true)
		
		original_transform = transform
		
		#print("og %s\n new %s" % [original_transform, target_transform])
		current_state = State.MOVING_TO_MARKER
		
		tween = get_tree().create_tween() # Create a new tween for each sequence
		tween.tween_callback(Callable(self, "_on_reached_marker")) 
		tween.tween_property(self, "transform", target_transform, interpolation_duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT) # Smooth start/end
	elif val == false:
		if current_state != State.AT_MARKER: return
		tween = get_tree().create_tween()
		Global.focus_cam.emit(false)
		current_state = State.RETURNING_TO_ORIGINAL
		tween.tween_callback(Callable(self, "_on_tween_finished")) # Call function when interval finishes
		
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "transform", original_transform, interpolation_duration)

		# Connect a signal to know when the whole tween sequence finishes
		tween.finished.connect(_on_tween_finished)

func take_photo():
	if is_taking_photo == true: return
	is_taking_photo = true
	print("is taking photo? %s" % is_taking_photo)
	Global.photo_taken.emit()
	if tween == null: 
		tween = get_tree().create_tween()
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(flash, "light_energy", 1.5, 0.1)
	tween.chain()
	tween.tween_property(flash, "light_energy", 0, .5)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	is_taking_photo = false
	
	

func _on_reached_marker():
	current_state = State.AT_MARKER
	print("reached")
	Global.cam_reached_marker.emit()
	

func _on_tween_finished():
	current_state = State.IDLE
	print("Returned to original!")
	tween = null # Clear the tween reference
	Global.focus_cam.emit(false)



func _process(_delta):
	cam.global_transform = marker.global_transform
	#if current_state == State.IDLE:
		#self.look_at(look_marker.global_position, Vector3.LEFT)
		#self.look_at(look_marker.global_position, Vector3.UP)
	#material_override.shader.set_shader_parameter("")
	
