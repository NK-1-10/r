extends ColorRect

var target_square: String = ""

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		execute_move()

func execute_move() -> void:
	var piece = GlobalChess.cPiece
	if piece == null:
		return
	
	var old_square = piece.current_square
	
	# capture: remove the captured piece's node if present
	if GlobalChess.live_board.has(target_square):
		var captured_node = GlobalChess.live_board[target_square]["node"]
		if captured_node:
			captured_node.queue_free()
	
	# update board data
	GlobalChess.live_board.erase(old_square)
	GlobalChess.live_board[target_square] = {
		"type": piece.piece_type,
		"color": piece.piece_color,
		"node": piece
	}
	
	# move the piece visually — reuse movement.gd's coordinate math
	var horizontal = ["a", "b", "c", "d", "e", "f", "g", "h"]
	var target_col = horizontal.find(target_square[0])
	var target_row = int(target_square[1])
	piece.position = Vector2(
		574.0 + target_col * 63,
		552 + (target_row - 1) * -62.5
	)
	piece.current_square = target_square
	
	GlobalChess.cPiece = null
	Signals.highlights.emit()  # tell movement.gd to clear markers
