extends Node


signal focus_cam(val:bool)
signal cam_reached_marker()
signal photo_taken(tex:ViewportTexture)

# Game
signal game_state_changed(new)
var game_state = 0:
	set(val):
		if val == game_state: return
		self.game_state_changed.emit(val)
		game_state = val
signal image_added(image)
func add_image(im):
	image_added.emit(im)
	images.append(im)
var images : Array[Texture2D] = [] 
var scores : Array[float] = []
enum Game {
	MAIN_MENU,
	CAVE_RUNNING,
	DIED,
	END,
}

# Maze
## True if entered, false if exited. 
signal maze_entered(val:bool) 
var is_in_maze = false

# Artifacts
var artifacts : Array[Artifact] = []

# Player
signal player_pos_changed
var player_pos : Vector3 :
	set(new_pos):
		player_pos_changed.emit(new_pos)
		player_pos = new_pos

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
