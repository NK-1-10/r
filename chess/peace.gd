extends Node2D

@onready var sprite: Sprite2D = $peace

var piece_type: String = ""
var piece_color: String = ""
var current_square: String = ""

func setup_piece(type: String, color: String, square: String, texture_path: String) -> void:
	piece_type = type
	piece_color = color
	current_square = square
	name = color + "_" + type + "_" + square
	if sprite:
		sprite.texture = load(texture_path)
