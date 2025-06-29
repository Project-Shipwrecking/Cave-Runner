## Here to calculate score using Global variables and artifacts
class_name World extends Node3D

@onready var ui := $CanvasLayer/UI as UI
@onready var main := $CanvasLayer/MainMenu as MainMenu
@onready var pause := $CanvasLayer/PauseMenu as PauseMenu

func _ready():
	Global.photo_taken.connect(calc_score)
	Global.game_state_changed.connect(_check_need_calc)
	get_tree().paused = true

func calc_score(_im) -> float:
	var total := 0.
	for art in Global.artifacts:
		total += art.get_score()
	Global.scores.append(total+randf())
	return total

func _check_need_calc(new):
	if new != Global.Game.END: return
	$CanvasLayer/UI/VBoxContainer.visible = true
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

func _unhandled_input(event: InputEvent) -> void:
	match Global.game_state:
		Global.Game.CAVE_RUNNING:
			if event.is_action_pressed("exit"):
				pause.open()
		Global.Game.END:
			if event.is_action_pressed("exit"):
				pause.open()
		Global.Game.PAUSE_MENU:
			if event.is_action_pressed("exit"):
				get_tree().quit()
		

func _on_leave_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"): return
	print("ending")
	Global.game_state = Global.Game.END
