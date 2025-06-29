extends Node3D

@onready var flashlight := $FlashlightModel as CSGCombiner3D
@onready var igcam := $InGameCam as InGameCam
@onready var image_scene = preload("res://Scenes/image_scene.tscn")
@onready var image_shader = preload("res://Shaders/image.gdshader")

var holding_cam := false
var images : Array = []

func _ready():
	holding_cam = igcam.visible
	Global.photo_taken.connect(_on_photo_taken)

#TODO Get animations
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		if flashlight.visible == false:
			igcam.visible = false
			flashlight.visible = true
			holding_cam = false
	elif event.is_action_pressed("camera"):
		if igcam.visible == false:
			flashlight.visible = false
			igcam.visible = true
			holding_cam = true
func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("right_click"):
		igcam.hold_cam(true)
	elif Input.is_action_just_released("right_click"):
		igcam.hold_cam(false)
	elif Input.is_action_just_pressed("left_click"):
		if holding_cam == true or igcam.visible:
			igcam.take_photo()

func _on_photo_taken(tex:ViewportTexture):
	var image = tex.get_image()
	image.convert(Image.FORMAT_RGBA8)
	var static_texture = ImageTexture.create_from_image(image)
	images.append(static_texture)
	
	
	var image_instance :MeshInstance3D = image_scene.instantiate()
	get_tree().current_scene.add_child(image_instance)
	
	var forward_vector: Vector3 = -global_transform.basis.z
	# Calculate the target global position for the new object
	var target_global_position: Vector3 = global_transform.origin + (forward_vector * 2)
	image_instance.global_position = target_global_position
	image_instance.look_at(global_position, Vector3.UP)
	
	var material = ShaderMaterial.new()
	material.shader = image_shader
	material.set_shader_parameter("albedo_texture", static_texture)
	
	image_instance.material_override = material
	
	await get_tree().create_timer(2).timeout
	image_instance.queue_free()
