extends SpotLight3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		visible = !visible
