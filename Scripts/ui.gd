class_name UI extends Control

@onready var sprint_meter := $SprintMeter as TextureProgressBar
@onready var sprint_timer := $SprintMeter/Timer as Timer
var sprint_value :float = 100. :
	set(val):
		if Global.game_state != Global.Game.CAVE_RUNNING: 
			sprint_meter.visible = false
			return
		val = clamp(val, sprint_meter.min_value, sprint_meter.max_value)
		if val == sprint_meter.value: return
		sprint_meter.value = val
		sprint_value = val
		if val == 100: sprint_meter.visible = false
		else: sprint_meter.visible = true
		#print_debug(sprint_meter.value)



func _on_timer_timeout() -> void:
	sprint_value += 0.3
