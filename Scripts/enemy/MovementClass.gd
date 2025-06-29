class_name MovementClass

var direction : Vector2 = Vector2(0,0)
var speed : float
var start : Vector3 = Vector3.ZERO
var distance : float


func calculate(initial_pos: Vector3, final_pos: Vector3, speed):	
	start = initial_pos
	var difference: Vector3 = final_pos - initial_pos
	distance = difference.length()
	difference = difference.normalized()
	direction = Vector2(difference.x,difference.y)
	self.speed = speed
	
