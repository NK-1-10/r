extends Node2D
@onready var BOX = $"."
@onready var box = $box
@onready var bow = $bow
@onready var string = $string

var boxStart = Vector2(1220.0, -616.0)

func _ready() -> void:
	Signals.box_drop.connect(on_box_drop)
	BOX.position = boxStart
	box.animation = &"bow"
	BOX.freeze = true
	bow.process_mode = Node.PROCESS_MODE_DISABLED; bow.visible = false
	string.process_mode = Node.PROCESS_MODE_DISABLED; string.visible = false

func on_box_drop():
	BOX.freeze = false
