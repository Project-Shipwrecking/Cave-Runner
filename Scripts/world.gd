## Here to calculate score using Global variables and artifacts
class_name World extends Node3D

func _ready():
	Global.photo_taken.connect(calc_score)
	Global.game_state_changed.connect(_check_need_calc)

func calc_score(_im) -> float:
	var total := 0.
	for art in Global.artifacts:
		total += art.get_score()
	return total

func _check_need_calc(_old_state:int):
	#if Global.game_state != Global.Game.END: return
	var total : float = 0
	for i in range(len(Global.images)):
		_present(Global.images[i], Global.scores[i], i)
		total += Global.scores[i]

func _present(image, score, index):
	#TODO present this to player
	pass
