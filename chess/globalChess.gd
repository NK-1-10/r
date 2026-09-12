extends Node

var player = "w" # "w" or "b"
var turn = "w"

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
	
	for i in range(8):
		var f = FILES[i]

		live_board[f + "1"] = {"type": BACK_RANK[i], "color": "black", "node": null}
		live_board[f + "2"] = {"type": "pawn", "color": "black", "node": null}
		
		live_board[f + "7"] = {"type": "pawn", "color": "white", "node": null}
		live_board[f + "8"] = {"type": BACK_RANK[i], "color": "white", "node": null}
		
