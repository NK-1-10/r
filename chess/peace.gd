extends Node2D

@onready var sprite: Sprite2D = $peace

var piece_type: String = ""
var piece_color: String = ""
var current_square: String = ""

func _ready() -> void:
	# temporary debug
	var area = $peace/square if has_node("peace/square") else $square


func setup_piece(type: String, color: String, square: String, texture_path: String) -> void:
	piece_type = type
	piece_color = color
	current_square = square
	name = color + "_" + type + "_" + square
	if sprite:
		sprite.texture = load(texture_path)

func _on_square_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("PIECE CLICKED: ", name)
		var my_short_color = "w" if piece_color == "white" else "b"
		if my_short_color != GlobalChess.turn:
			print("turn mismatch: ", my_short_color, " vs ", GlobalChess.turn)
			return
		print("about to emit on Signals instance: ", Signals)
		Signals.move.emit(self)
