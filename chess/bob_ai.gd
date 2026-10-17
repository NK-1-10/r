extends Node

func _ready() -> void:
	Signals.highlights.connect(_check_bob_turn)
	var mv = get_node("/root/chess/movemen")
	print("Movement node found: ", mv)

func _check_bob_turn() -> void:
	var bob_color = "black" if GlobalChess.player == "w" else "white"
	var bob_short = "b" if GlobalChess.player == "w" else "w"
	
	if GlobalChess.turn != bob_short:
		return
	
	await get_tree().create_timer(0.5).timeout  # small pause so it doesn't feel instant
	
	var bob_pieces = []
	for square in GlobalChess.live_board.keys():
		var data = GlobalChess.live_board[square]
		if data["color"] == bob_color and data["node"] != null:
			bob_pieces.append(data["node"])
	
	bob_pieces.shuffle()
	
	for piece in bob_pieces:
		var moves = get_node("movemen").get_valid_moves(piece)
		if moves.size() > 0:
			var chosen_square = moves[randi() % moves.size()]
			GlobalChess.execute_move(piece, chosen_square)
			return
	
	print("Bob has no legal moves!")
