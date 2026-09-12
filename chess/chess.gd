extends Node2D

@export var x_step: float = 71.0
@export var y_step: float = -70.0

@onready var marker_template: Marker2D = $Marker2D
@onready var peace_template = $peace

var horizontal = ["a", "b", "c", "d", "e", "f", "g", "h"]
var vertical = [1, 2, 3, 4, 5, 6, 7, 8]

var x_starting: float = 1488.0
var y_starting: float = 1025.0

var board_positions = {}

func _ready() -> void:
	GlobalChess.setup_board(GlobalChess.player)
	generate_board()

func generate_board() -> void:
	for row in range(8):
		for col in range(8):
			var tile_coord = str(horizontal[col]) + str(vertical[row])
			var world_position = Vector2(
				x_starting + (col * x_step),
				y_starting + (row * y_step)
			)
			
			var new_marker = marker_template.duplicate()
			new_marker.position = world_position
			new_marker.name = "Marker_" + tile_coord
			new_marker.visible = true
			add_child(new_marker)
			
			# Inside generate_board(), right before spawning:
			if tile_coord.ends_with("2"):
				print("Rank 2 Tile: ", tile_coord, " -> Data: ", GlobalChess.live_board.get(tile_coord))
						
			board_positions[tile_coord] = world_position
			
			if GlobalChess.live_board.has(tile_coord):
				var piece_info = GlobalChess.live_board[tile_coord]
				print("Spawning: ", piece_info["color"], " ", piece_info["type"], " at ", tile_coord, " Position: ", world_position)
				spawn_piece_sprite(tile_coord, piece_info)
	

func spawn_piece_sprite(tile_coord: String, piece_info: Dictionary) -> void:
	var type = piece_info["type"]
	var color = piece_info["color"]
	
	var templates = GlobalChess.white_templates if color == "white" else GlobalChess.black_templates
	var texture_path = templates[type]["image"]
	
	var piece_node = peace_template.duplicate()
	piece_node.position = board_positions[tile_coord]
	piece_node.visible = true
	add_child(piece_node)
	
	piece_node.setup_piece(type, color, tile_coord, texture_path)
	
	GlobalChess.live_board[tile_coord]["node"] = piece_node

func game_end() -> void:
	GlobalChess.turn = "b" if GlobalChess.turn == "w" else "w"
