extends Node2D

# maze configuration
var maze_size: Vector2         = Vector2(7, 7)  # 5x5 maze
var maze: Array[Array]         = []
var origin_pos: Vector2
var cell_size: float           = 150.0  # Reduced size for better visibility
var arrow_size: float          = 10.0

var directions: Array[Vector2] = [Vector2(-1, 0),
								 Vector2(1, 0),
								 Vector2(0, -1),
								 Vector2(0, 1)
								 ]


func _ready():
	origin_pos = Vector2(maze_size.x - 1, maze_size.y - 1)
	generateMaze()
	queue_redraw()  # Request a redraw after setup


func generateMaze() -> Array[Array]:
	for x in range(maze_size.x):
		var row: Array[NodeData] = []
		for y in range(maze_size.y):
			var node = Node2D.new()
			node.name = "Node_%d_%d" % [x, y]
			node.position = Vector2(x, y) * cell_size

			var node_data = NodeData.new(node, Vector2(x, y))
			row.append(node_data)
			print(node_data.pos)
			add_child(node)  # Add node to scene immediately

		maze.append(row)

	setup_connections()
	
	return maze

var prev_dir = Vector2.ZERO

func _process(delta):
	#	# Handle the movement input to change the origin position
	#	if Input.is_action_pressed("Right"):
	#		move_origin(Vector2(1, 0))  # Move right
	#	elif Input.is_action_pressed("Left"):
	#		move_origin(Vector2(-1, 0))  # Move left
	#	elif Input.is_action_pressed("Up"):
	#		move_origin(Vector2(0, -1))  # Move up
	#	elif Input.is_action_pressed("Down"):
	#		move_origin(Vector2(0, 1))  # Move down
	if Input.is_action_pressed("jump"):
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

	if !(node_b.node_ref in node_a.connected_nodes):
		node_a.connected_nodes.append(node_b.node_ref)


func move_origin(dir: Vector2) -> bool:
	var new_pos: Vector2 = origin_pos + dir

	if !is_valid_position(new_pos):
		return false

	# Make sure the previous origin points towards the new origin
	if not maze[new_pos.x][new_pos.y].node_ref in maze[origin_pos.x][origin_pos.y].connected_nodes:
		maze[origin_pos.x][origin_pos.y].connected_nodes = [
			maze[new_pos.x][new_pos.y].node_ref
		]

	# Clear connections from new origin
	maze[new_pos.x][new_pos.y].connected_nodes = []
	origin_pos = new_pos
	queue_redraw()  # Request redraw after moving origin
	return true


func is_valid_position(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < maze_size.x and pos.y >= 0 and pos.y < maze_size.y


func _draw() -> void:
	# Draw nodes and connections
	for x in range(maze_size.x):
		for y in range(maze_size.y):
			var node_data = maze[x][y]
			var node_pos  = node_data.pos * cell_size

			# Draw node rectangle
			var rect: Rect2  = Rect2(node_pos, Vector2(cell_size * 0.5, cell_size * 0.5))
			var color: Color = Color(0.2, 0.2, 0.8, 1)

			# Highlight origin node
			if Vector2(x, y) == origin_pos:
				color = Color(0.8, 0.2, 0.2, 1)

			draw_rect(rect, color, true)

			# Draw connections with arrows
			for connected_node in node_data.connected_nodes:
				var connected_pos = connected_node.position
				var start = node_pos + Vector2(cell_size * 0.25, cell_size * 0.25)  # Start at the center of the node
				var end = connected_pos + Vector2(cell_size * 0.25, cell_size * 0.25)  # Center of the connected node

				# Draw connection line
				draw_line(start, end, Color(0.8, 0.8, 0.2), 2.0)
				draw_arrow(start, end)


func draw_arrow(start_pos: Vector2, end_pos: Vector2) -> void:
	var direction: Vector2  = (end_pos - start_pos).normalized()  # Get the direction of the arrow
	var arrow_base: Vector2 = end_pos - direction * arrow_size  # Determine the base of the arrow

	# Calculate arrow wings
	var angle: float       = PI / 6  # 30 degrees (angle for the arrow wings)
	var left_wing: Vector2  = arrow_base + direction.rotated(-angle) * arrow_size  # Left wing of the arrow
	var right_wing: Vector2 = arrow_base + direction.rotated(angle) * arrow_size  # Right wing of the arrow

	# Draw the arrow head
	draw_line(arrow_base, left_wing, Color(0.8, 0.8, 0.2), 2.0)
	draw_line(arrow_base, right_wing, Color(0.8, 0.8, 0.2), 2.0)


func print_node_data(pos: Vector2) -> void:
	if !is_valid_position(pos):
		print("Invalid position: ", pos)
		return

	var node = maze[pos.x][pos.y]
	print("Node Position: (%d, %d)" % [pos.x, pos.y])

	for connected_node in node.connected_nodes:
		print("Connected to: ", connected_node.name)
