class_name Artifact extends Node3D

var mesh : MeshInstance3D
var rarity : float = 1.
var score_per_rarity : float = 10
var seen_times : int = 0

func set_mesh(node : MeshInstance3D):
	add_child(node)
	mesh = node
## Uses an exponential curve to decrease score gotten per image. Also increases number of seen_times
func get_score() -> float:
	var score = exp(-(seen_times/10)) * rarity * score_per_rarity
	
	# Cut score if monster is in it
	if Global.monster_state == Util.EnemyState.FROZEN: score /= 2.7
	
	seen_times += 1
	return score

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	Global.artifacts.append(self)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	Global.artifacts.erase(self)
