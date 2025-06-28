class_name InGameCam extends MeshInstance3D

@onready var cam : Camera3D = $SubViewport/Camera3D
@onready var marker := $Marker3D as Marker3D
@onready var portal_shader: Shader = preload("res://Shaders/in_game_cam.gdshader")
@onready var viewport 

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

func _process(_delta):
	cam.global_transform = marker.global_transform
