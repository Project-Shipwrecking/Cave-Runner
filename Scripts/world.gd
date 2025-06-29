## Here to calculate score using Global variables and artifacts
class_name World extends Node3D

@onready var ui := $CanvasLayer/UI as UI

func _ready():
	Global.photo_taken.connect(calc_score)
	Global.game_state_changed.connect(_check_need_calc)

func calc_score(_im) -> float:
	var total := 0.
	for art in Global.artifacts:
		total += art.get_score()
	Global.scores.append(total+randf())
	return total

func _check_need_calc(new):
	if new != Global.Game.END: return
	var total : float = 0
	for i in range(len(Global.images)):
		print(Global.scores)
		_present(Global.images[i], Global.scores[i])
		total += Global.scores[i]
		await get_tree().create_tween().tween_property(self, "position", position, exp(-i/3)).finished
		continue

func _present(image, score):
	#TODO present this to player
	$CanvasLayer/UI/VBoxContainer/TextureRect.texture = image
	$CanvasLayer/UI/VBoxContainer/RichTextLabel.clear()
	$CanvasLayer/UI/VBoxContainer/RichTextLabel.append_text("[font_size=100]%s" % score)


func _on_leave_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	print("ending")
	Global.game_state = Global.Game.END
