extends ColorRect

var target_square: String = ""

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("marker input event: ", event)
	if event is InputEventMouseButton and event.pressed:
		print("marker clicked, target_square: ", target_square)
		execute_move()

func execute_move() -> void:
	print("execute_move called, cPiece: ", GlobalChess.cPiece)
	var piece = GlobalChess.cPiece
	if piece == null:
		print("cPiece is null, aborting")
		return
	
	var old_square = piece.current_square
	print("moving from ", old_square, " to ", target_square)
	
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
	
	var horizontal = ["a", "b", "c", "d", "e", "f", "g", "h"]
	var target_col = horizontal.find(target_square[0])
	var target_row = int(target_square[1])
	piece.position = Vector2(
		574.0 + target_col * 63,
		552 + (target_row - 1) * -62.5
	)
	piece.current_square = target_square
	
	GlobalChess.cPiece = null
	Signals.highlights.emit()
	print("move complete")
