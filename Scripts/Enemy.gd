extends CharacterBody3D
class_name Enemy


@onready var ai : Node3D = $EnemyAI
@onready var screen_check = $OnScreenCheck
const SPEED := 5.0
signal killed

func _ready():
	move_random()
	Global.connect("monster_state_changed", _on_state_change)
	
func _physics_process(delta: float) -> void:
	Global.monster_pos = get_global_position()
	
	velocity.y -= 9.8 * delta  # apply gravity
	move_and_slide()		
	Global.monster_pos = global_position
	#if Global.monster_state != Util.EnemyState.FROZEN:
		#self.look_at(Global.player_pos)



func move_random() -> void:
	if Global.monster_moving:
		return
	Global.monster_moving = true
	var random_dir = ai.random_dir()
	look_at_from_position(global_position, Vector3(random_dir.x, position.y, random_dir.y))
	var newMove := MovementClass.new()
	newMove.direction = random_dir
	newMove.distance = randf_range(1,2)
	newMove.speed = SPEED
	ai.pathfind(newMove, self)
	print_debug("random")

func move_toward_target_body() -> void:
	var movement = Global.player_pos - get_global_position()
	movement = movement.normalized() * SPEED
	velocity = movement
	#velocity.y = 0
	self.look_at(Global.player_pos)
	

func _on_state_change(state):
	if state == Util.EnemyState.IDLE:
		# print_debug("Monster sightline: %s" % Global.monster_unbroken_sightline)
		# print(Global.monster_state)
		if Global.monster_unbroken_sightline:
			move_random()
			print("working?")
		else:
			if Global.monster_seen:
				Global.monster_state = Util.EnemyState.FROZEN
			if not Global.monster_seen:
				Global.monster_state = Util.EnemyState.ATTACKING
	elif state == Util.EnemyState.FROZEN:
		velocity = Vector3.ZERO
	elif state == Util.EnemyState.ATTACKING:
		ai.pathfind_end()
		move_toward_target_body()
	elif state == Util.EnemyState.ROAMING:
		pass

func _on_enemy_ai_target_reached() -> void:
	Global.monster_state = Util.EnemyState.IDLE
	Global.monster_moving = false
	Global.monster_state_changed.emit(Global.monster_state)

func _on_sightline_screen_entered() -> void:
	Global.monster_seen = true
	Global.monster_state = Util.EnemyState.IDLE
	Global.monster_state_changed.emit(Global.monster_state)

func _on_sightline_screen_exited() -> void:
	Global.monster_seen = false
	Global.monster_state = Util.EnemyState.IDLE
	Global.monster_state_changed.emit(Global.monster_state)


func _on_kill_box_body_entered(body: Node3D) -> void:
	killed.emit()
	print("killed")
