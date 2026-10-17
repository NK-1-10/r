extends ColorRect

var target_square: String = ""

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if GlobalChess.cPiece:
			GlobalChess.execute_move(GlobalChess.cPiece, target_square)
