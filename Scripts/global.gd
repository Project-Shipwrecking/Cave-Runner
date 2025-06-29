extends Node


signal focus_cam(val:bool)
signal cam_reached_marker()
signal photo_taken(tex:ViewportTexture)

# Player
signal player_pos_changed
var player_pos : Vector3 :
	set(new_pos):
		player_pos_changed.emit(new_pos)
		player_pos = new_pos
var player_state : int

# Monster
signal monster_pos_changed
var monster_pos : Vector3:
	set(new_pos):
		monster_pos_changed.emit(new_pos)
		monster_pos = new_pos
signal monster_state_changed
var monster_state : int :
	set(state):
		if monster_state != state:
			monster_state_changed.emit(state)
			monster_state = state
signal monster_seen_changed
var monster_seen : bool :
	set(seen):
		monster_seen_changed.emit(seen)
		monster_seen = seen
signal unbroken_sightline_changed
var monster_unbroken_sightline : bool:
	set(unbroken):
		if monster_unbroken_sightline != unbroken:
			unbroken_sightline_changed.emit()
			monster_unbroken_sightline = unbroken
signal update_sightline
var monster_moving : bool = false
