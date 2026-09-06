extends Node2D
@onready var BOX = $"."
@onready var box = $box
@onready var bow = $bow
@onready var string = $string

func _ready() -> void:
	box.animation = &"bow"
	bow.process_mode = Node.PROCESS_MODE_DISABLED; bow.visible = false
	string.process_mode = Node.PROCESS_MODE_DISABLED; string.visible = false


func _process(delta: float) -> void:
	pass


func on_clicked(what):
	what.process_mode = Node.PROCESS_MODE_DISABLED; what.visible = false
