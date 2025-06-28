extends Node3D

@onready var flashlight := $FlashlightModel as CSGCombiner3D
@onready var igcam := $InGameCam as InGameCam

var holding_cam := false

func _ready():
	holding_cam = igcam.visible

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
	
