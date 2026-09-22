extends Node

@onready var green = $green
@onready var red = $red

var maxLeft = 574.0
var maxDown = 552
var maxUp = maxDown + (-62.5)*8
var maxRight = maxLeft + 63*8

var horizontal = ["a", "b", "c", "d", "e", "f", "g", "h"]

func _ready() -> void:
	Signals.move.connect(_move)
	Signals.highlights.connect(clear_highlights)

func _move(what: Node2D) -> void:
	GlobalChess.cPiece = what
	clear_highlights()
	var type = what.piece_type
	var my_color = what.piece_color

	var col = what.current_square[0]
	var row = int(what.current_square[1])
	
	var moves: Array = []
	
	if type == "pawn":
		var is_player_piece = (what.piece_color == "white" and GlobalChess.player == "w") or (what.piece_color == "black" and GlobalChess.player == "b")
		var direction = 1 if is_player_piece else -1
		var start_row = 2 if is_player_piece else 7
		
		if row == start_row:
			for a in range(1, 3):
				var target_row = row + a * direction
				if target_row < 1 or target_row > 8:
					break
				var square = col + str(target_row)
				if GlobalChess.live_board.has(square):
					break
				moves.append(square)
				_check(square, my_color)
		else:
			var target_row = row + direction
			if target_row >= 1 and target_row <= 8:
				var square = col + str(target_row)
				if not GlobalChess.live_board.has(square):
					moves.append(square)
					_check(square, my_color)
		
	elif type == "rook":
		var where = horizontal.find(col)
		var directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]
		moves = get_sliding_moves(where, row, directions, my_color)
		
	elif type == "knight":
		var where = horizontal.find(col)
		var offsets = [
			[-2, -1], [-2, 1], [-1, -2], [-1, 2],
			[1, -2], [1, 2], [2, -1], [2, 1]
		]
		moves = get_stepping_moves(where, row, offsets, my_color)
		
	elif type == "bishop":
		var where = horizontal.find(col)
		var directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
		moves = get_sliding_moves(where, row, directions, my_color)
		
	elif type == "queen":
		var where = horizontal.find(col)
		var directions = [
			[1, 0], [-1, 0], [0, 1], [0, -1],
			[1, 1], [1, -1], [-1, 1], [-1, -1]
		]
		moves = get_sliding_moves(where, row, directions, my_color)
		
	elif type == "king":
		var where = horizontal.find(col)
		var directions = [
			[1, 0], [-1, 0], [0, 1], [0, -1],
			[1, 1], [1, -1], [-1, 1], [-1, -1]
		]
		moves = get_stepping_moves(where, row, directions, my_color)


func get_sliding_moves(where: int, row: int, directions: Array, my_color: String) -> Array:
	var result: Array = []
	for dir in directions:
		var step = 1
		while true:
			var target_col = where + dir[0] * step
			var target_row = row + dir[1] * step
			
			if target_col < 0 or target_col >= horizontal.size():
				break
			if target_row < 1 or target_row > 8:
				break
			
			var square = horizontal[target_col] + str(target_row)
			result.append(_check(square, my_color))
			
			if GlobalChess.live_board.has(square):
				break
			
			step += 1
	return result.filter(func(x): return x != null)

func get_stepping_moves(where: int, row: int, offsets: Array, my_color: String) -> Array:
	var result: Array = []
	for offset in offsets:
		var target_col = where + offset[0]
		var target_row = row + offset[1]
		
		if target_col < 0 or target_col >= horizontal.size():
			continue
		if target_row < 1 or target_row > 8:
			continue
		
		var square = horizontal[target_col] + str(target_row)
		result.append(_check(square, my_color))
	return result.filter(func(x): return x != null)


func _check(square: String, my_color: String):
	var target_col = horizontal.find(square[0])
	var target_row = int(square[1])
	
	# center the marker on the square instead of anchoring top-left
	var half_w = green.size.x / 2.0
	var half_h = green.size.y / 2.0
	
	var world_pos = Vector2(
		maxLeft + target_col * 63 - half_w,
		maxDown + (target_row - 1) * -62.5 - half_h
	)
	
	if not GlobalChess.live_board.has(square):
		var new_green = green.duplicate()
		new_green.position = world_pos
		new_green.visible = true
		new_green.target_square = square
		new_green.add_to_group("highlight_markers")
		add_child(new_green)
		return square
	
	if GlobalChess.live_board[square]["color"] != my_color:
		var new_red = red.duplicate()
		new_red.position = world_pos
		new_red.visible = true
		new_red.target_square = square
		new_red.add_to_group("highlight_markers")
		add_child(new_red)
		return square
	
	return null

func clear_highlights() -> void:
	for marker in get_tree().get_nodes_in_group("highlight_markers"):
		marker.queue_free()
