extends Node2D

@onready var box = $box
@onready var ground = $walls/ground
@onready var below = $walls/once

var hits = 0
var can_move = false
var can_press = false

var grabOffset = Vector2.ZERO
var mouseP = Vector2()

var FOLLOW_STRENGTH = 50.0
var DAMPING = 10.0

func _ready() -> void:
	Signals.change_text.emit("You've got mail !", true, false, true) #(what_text, first, end, header)
	await Signals.text_done
	Signals.change_text.emit("Seems you have gotten a message in the mail. this should be interesting...", false, true, false) #(what_text, first, end, header)
	await Signals.text_done
	Signals.box_drop.emit()

func _physics_process(_delta: float) -> void:
	if can_move:
		mouseP = get_global_mouse_position()
		var grabPoint = box.to_global(grabOffset)
		var to_mouse = mouseP - grabPoint
		var force = to_mouse * FOLLOW_STRENGTH - box.linear_velocity * DAMPING
		force = force.limit_length(2000.0)
		box.apply_force(force, grabPoint - box.global_position)

func _on_box_body_entered(body: Node) -> void:
	if body == ground or body == below:
		hits += 1
		if hits == 1:
			Signals.change_text.emit("Try getting it open with your mouse.", true, true, false) #(what_text, first, end, header)
			await Signals.text_done

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if can_press and hits >= 1:
				grabOffset = box.to_local(get_global_mouse_position())
				can_move = true
		else:
			can_move = false

func _on_box_move_mouse_entered() -> void:
	can_press = true

func _on_box_move_mouse_exited() -> void:
	can_press = false
