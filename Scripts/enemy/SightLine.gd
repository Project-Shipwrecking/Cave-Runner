extends RayCast3D


func _ready() -> void:
	Global.connect("player_pos_changed", _on_player_pos)
	Global.connect("monster_pos_changed", _on_monster_pos)
	Global.connect("update_sightline", update_sightline)

func _on_player_pos(pos : Vector3):
	update_sightline()

func _on_monster_pos(pos : Vector3):
	update_sightline()

func update_sightline():
	global_position = Global.monster_pos
	target_position = - global_position + Global.player_pos
	if Global.monster_unbroken_sightline != is_colliding():
		Global.monster_unbroken_sightline = is_colliding()
		if is_colliding():
			Global.monster_state = Util.EnemyState.IDLE
			Global.monster_state_changed.emit(Global.monster_state)
	

	
	
