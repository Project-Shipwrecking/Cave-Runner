extends Marker3D

var cam : Camera3D

func _ready():
	cam = get_viewport().get_camera_3d()

func _process(_delta):
	#transform = cam.transform
	# Get the camera's global position
		var camera_position = cam.global_position

		# Get the camera's forward direction (local Z-axis) in global coordinates
		# For a Camera3D, its local +Z is typically forward.
		# So, -1.0 * basis.z moves it backward along the camera's view direction.
		var camera_forward_direction = cam.global_transform.basis.z

		# Calculate the marker's new global position
		# camera_position + (camera_forward_direction * offset_z)
		# If offset_z is -1.0, it's: camera_position + (forward_direction * -1.0)
		# which means camera_position - forward_direction
		global_position = camera_position + (camera_forward_direction * -0.3)

		# Optional: If you want the marker to also *inherit the camera's rotation*:
		global_rotation = cam.global_rotation
		# Or, if you want it to always be upright relative to the world:
		# global_rotation = Vector3(0, camera.global_rotation.y, 0) # Only yaw rotation
