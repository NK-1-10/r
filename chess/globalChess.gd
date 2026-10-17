extends Node

var player = "w" # "w" or "b"
var turn = "w"


var cPiece

var white_templates = {
	"pawn": {"name": "pawn", "image": "res://asstes/chess/whitepawn.PNG", "points": 1},
	"rook": {"name": "rook", "image": "res://asstes/chess/whiterook.PNG", "points": 5},
	"knight": {"name": "knight", "image": "res://asstes/chess/whitehorse.PNG", "points": 3},
	"bishop": {"name": "bishop", "image": "res://asstes/chess/whitebishop.PNG", "points": 3},
	"queen": {"name": "queen", "image": "res://asstes/chess/whitequeen.PNG", "points": 9},
	"king": {"name": "king", "image": "res://asstes/chess/whiteking.PNG", "points": 0}
}

var black_templates = {
	"pawn": {"name": "pawn", "image": "res://asstes/chess/blckpawn.PNG", "points": 1},
	"rook": {"name": "rook", "image": "res://asstes/chess/blackrook.PNG", "points": 5},
	"knight": {"name": "knight", "image": "res://asstes/chess/blackhorse.PNG", "points": 3},
	"bishop": {"name": "bishop", "image": "res://asstes/chess/blackbishop.PNG", "points": 3},
	"queen": {"name": "queen", "image": "res://asstes/chess/blackqueen.PNG", "points": 9},
	"king": {"name": "king", "image": "res://asstes/chess/blackking.PNG", "points": 0}
}

var live_board = {}
const BACK_RANK = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
const FILES = ["a", "b", "c", "d", "e", "f", "g", "h"]

func setup_board(player_color: String) -> void:
	live_board.clear()
	
	var opponent_color = "black" if player_color == "w" else "white"
	var player_full = "white" if player_color == "w" else "black"
	
	for i in range(8):
		var f = FILES[i]

		live_board[f + "1"] = {"type": BACK_RANK[i], "color": player_full, "node": null}
		live_board[f + "2"] = {"type": "pawn", "color": player_full, "node": null}
		
		live_board[f + "7"] = {"type": "pawn", "color": opponent_color, "node": null}
		live_board[f + "8"] = {"type": BACK_RANK[i], "color": opponent_color, "node": null}
		
# add to globalChess.gd
var horizontal = ["a", "b", "c", "d", "e", "f", "g", "h"]

func square_to_position(square: String) -> Vector2:
	var col = horizontal.find(square[0])
	var row = int(square[1])
	return Vector2(
		574.0 + col * 63,
		552 + (row - 1) * -62.5
	)

func get_block_distance(from_square: String, to_square: String) -> float:
	var from_col = horizontal.find(from_square[0])
	var from_row = int(from_square[1])
	var to_col = horizontal.find(to_square[0])
	var to_row = int(to_square[1])
	return max(abs(to_col - from_col), abs(to_row - from_row))

func execute_move(piece: Node2D, target_square: String) -> void:
	var old_square = piece.current_square
	var speedPerBlock = 0.5
	
	if live_board.has(target_square):
		var captured_node = live_board[target_square]["node"]
		if captured_node:
			captured_node.queue_free()
	
	live_board.erase(old_square)
	live_board[target_square] = {
		"type": piece.piece_type,
		"color": piece.piece_color,
		"node": piece
	}
	
	var target_pos = square_to_position(target_square)
	
	if piece.piece_type == "knight":
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
	else:
		var distance_blocks = get_block_distance(old_square, target_square)
		var duration = distance_blocks * speedPerBlock
		var tween = piece.create_tween()
		tween.tween_property(piece, "position", target_pos, duration)
	
	piece.current_square = target_square
	cPiece = null
	turn = "b" if turn == "w" else "w"
	Signals.highlights.emit()
