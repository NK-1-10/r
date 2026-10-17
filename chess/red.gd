extends ColorRect

var target_square: String = ""
var horizontal = ["a", "b", "c", "d", "e", "f", "g", "h"]
var speedPerBlock = 0.4

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		execute_move()

func execute_move() -> void:
	var piece = GlobalChess.cPiece
	if piece == null:
		return
	
	var old_square = piece.current_square
	
	if GlobalChess.live_board.has(target_square):
		var captured_node = GlobalChess.live_board[target_square]["node"]
		if captured_node:
			captured_node.queue_free()
	
	GlobalChess.live_board.erase(old_square)
	GlobalChess.live_board[target_square] = {
		"type": piece.piece_type,
		"color": piece.piece_color,
		"node": piece
	}
	
	var target_pos = square_to_position(target_square)
	
	if piece.piece_type == "knight":
		_tween_knight_move(piece, old_square, target_pos)
	else:
		var distance_blocks = get_block_distance(old_square, target_square)
		var duration = distance_blocks * speedPerBlock
		var tween = piece.create_tween()
		tween.tween_property(piece, "position", target_pos, duration)
	
	piece.current_square = target_square
	
	GlobalChess.cPiece = null
	Signals.highlights.emit()


func get_block_distance(from_square: String, to_square: String) -> float:
	var from_col = horizontal.find(from_square[0])
	var from_row = int(from_square[1])
	var to_col = horizontal.find(to_square[0])
	var to_row = int(to_square[1])
	
	var col_diff = abs(to_col - from_col)
	var row_diff = abs(to_row - from_row)
	
	return max(col_diff, row_diff)  # diagonal counts as 1 block per step, same as straight


func square_to_position(square: String) -> Vector2:
	var col = horizontal.find(square[0])
	var row = int(square[1])
	return Vector2(
		574.0 + col * 63,
		552 + (row - 1) * -62.5
	)


func _tween_knight_move(piece: Node2D, old_square: String, target_pos: Vector2) -> void:
	var old_col = horizontal.find(old_square[0])
	var old_row = int(old_square[1])
	var new_col = horizontal.find(target_square[0])
	var new_row = int(target_square[1])
	
	var col_diff = new_col - old_col
	var row_diff = new_row - old_row
	
	var midpoint: Vector2
	if abs(col_diff) == 2:
		midpoint = square_to_position(horizontal[old_col + col_diff] + str(old_row))
	else:
		midpoint = square_to_position(old_square[0] + str(old_row + row_diff))
	
	var tween = piece.create_tween()
	tween.tween_property(piece, "position", midpoint, speedPerBlock)
	tween.tween_property(piece, "position", target_pos, speedPerBlock)
