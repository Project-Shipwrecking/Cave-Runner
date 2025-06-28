extends Node3D

@onready var flashlight := $FlashlightModel as CSGCombiner3D
@onready var igcam := $InGameCam as InGameCam



#TODO Get animations
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		if flashlight.visible == false:
			igcam.visible = false
			flashlight.visible = true
	elif event.is_action_pressed("camera"):
		if igcam.visible == false:
			flashlight.visible = false
			igcam.visible = true
		
	
