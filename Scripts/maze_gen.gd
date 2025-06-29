class_name MazeGenerator extends GridMap

# maze configuration
var maze_size: Vector2         = Vector2(7, 7)  # 5x5 maze
var maze: Array[Array]         = []
var origin_pos: Vector2

var directions: Array[Vector2] = [Vector2(-1, 0),
								 Vector2(1, 0),
								 Vector2(0, -1),
								 Vector2(0, 1)
								 ]


func _ready():
	origin_pos = Vector2(maze_size.x - 1, maze_size.y - 1)
	generateMaze()
	#queue_redraw()  # Request a redraw after setup


func generateMaze() -> Array[Array]:
	self.clear()
	_gen_borders()
			
	
	for x in range(maze_size.x):
		var row: Array[NodeData] = []
		for y in range(maze_size.y):

			var node_data = NodeData.new(Vector2(x, y))
			row.append(node_data)
			set_cell_item(Vector3i(x,0,y)*2+Vector3i(1,0,1), 1)  # Set the corners to be full
			
	
		maze.append(row)
	# Set all walls to be 1
	for x in range(0, (maze_size.x)*2):
		for y in range(0, (maze_size.y)*2):
			if y%2 != x%2:
				set_cell_item(Vector3i(x,0,y),1)
	setup_connections()
	
	_open_entrance_exit()
	return maze

func _open_entrance_exit():
	set_cell_item(Vector3i(-1,0,0),0)
	#.position = map_to_local(Vector3(-1,0,0))
	set_cell_item(Vector3i(maze_size.x*2-2,0,maze_size.y*2-1),0)
	

func _gen_borders():
	for x in range(-1,(maze_size.x)*2):
		set_cell_item(Vector3i(x,0,-1),1)
		set_cell_item(Vector3i(x,0,maze_size.y*2-1),1)
	for y in range(0,(maze_size.y)*2):
		set_cell_item(Vector3i(-1,0,y),1)
		set_cell_item(Vector3i(maze_size.x*2-1,0,y),1)
	#for x in range(-1,(maze_size.x)*2):
		#for y in range(0,(maze_size.y)*2):
			#set_cell_item(Vector3i(x,1,y),3,0)

var prev_dir = Vector2.ZERO

func _process(_delta):
	#_bring_to_3d()
	if Input.is_action_pressed("maze"):
		while true:
			var direc = directions[randi_range(0, 3)]
			while direc * -1 == prev_dir:
				direc = directions[randi_range(0, 3)]
			if move_origin(direc):
				prev_dir = direc
				break;
			


func setup_connections() -> void:
	for x in range(maze_size.x):
		for y in range(maze_size.y):
			if x == maze_size.x - 1:
				# If we're not on the bottom row, point down
				if y < maze_size.y - 1:
					point_node(Vector2(x, y), Vector2(0, 1))
				# For all other columns, point right
			elif x < maze_size.x - 1:
				point_node(Vector2(x, y), Vector2(1, 0))


func point_node(pos: Vector2, dir: Vector2) -> void:
	if !is_valid_position(pos) or !is_valid_position(pos + dir):
		return

	var node_a = maze[pos.x][pos.y]
	var node_b = maze[pos.x + dir.x][pos.y + dir.y]

	if !(node_b in node_a.connected_nodes):
		node_a.connected_nodes.append(node_b)
		_wall(node_a.pos, node_b.pos, 0)

func _wall(pos1:Vector2i, pos2:Vector2i, id:int = 1):
	var mid = (pos1 + pos2) 
	set_cell_item(Vector3i(mid.x, 0, mid.y),id)

func move_origin(dir: Vector2) -> bool:
	var new_pos: Vector2 = origin_pos + dir

	if !is_valid_position(new_pos):
		return false

	set_cell_item(Vector3i(origin_pos.x*2,0,origin_pos.y*2),0)
	set_cell_item(Vector3i(new_pos.x*2,0,new_pos.y*2),2)
	
	
	# Clear connections from new origin
	var new = maze[new_pos.x][new_pos.y]
	for node in new.connected_nodes:
		_wall(new.pos, node.pos, 1)
	maze[new_pos.x][new_pos.y].connected_nodes = []
	
	# Make sure the previous origin points towards the new origin
	if not maze[new_pos.x][new_pos.y] in maze[origin_pos.x][origin_pos.y].connected_nodes:
		point_node(origin_pos, dir)

	origin_pos = new_pos
	
	return true

func _get_neighbor_data(pos:Vector2) -> Array[NodeData]:
	var out = []
	for dir in directions:
		out.append(maze[pos.x+dir.x][pos.y+dir.y])
	return out
	
func is_valid_position(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < maze_size.x and pos.y >= 0 and pos.y < maze_size.y

func print_node_data(pos: Vector2) -> void:
	if !is_valid_position(pos):
		print("Invalid position: ", pos)
		return

	var node = maze[pos.x][pos.y]
	print("Node Position: (%d, %d)" % [pos.x, pos.y])

	for connected_node in node.connected_nodes:
		print("Connected to: ", connected_node.name)

var point_to_body : Vector3



#func _on_entrance_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#if body.name == "Maze": return
	#print(body.name)


#func _on_entrance_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#if body is not Player: return
	#var new_point = body.global_position - self.global_position
	#var sign_og = sign(self.global_transform.basis.x.normalized()\
			#.dot(point_to_body.normalized()))
	#var sign_new = sign(self.global_transform.basis.x.normalized()\
			#.dot(new_point.normalized()))
	#print(self.global_transform.basis.x.normalized()\
			#.dot(point_to_body.normalized()))
	#print(self.global_transform.basis.x.normalized()\
			#.dot(new_point.normalized()))
	#if sign_og != sign_new:
		#print_debug("entered!")
		#Global.is_in_maze == true
		#Global.maze_entered.emit(true)



func _on_maze_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Global.is_in_maze == true
		Global.maze_entered.emit(true)


func _on_maze_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Global.is_in_maze == false
		Global.maze_entered.emit(false)
