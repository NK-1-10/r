extends Node2D

@onready var box = $box
@onready var ground = $walls/ground
@onready var below = $walls/once
@onready var panel = $CanvasLayer/Panel
@onready var trash = $trash
@onready var bow = $bow
@onready var string = $string

@export var cip = 25

var co = Color(0.745, 0.231, 0.161, 1.0)

var hits = 0
var can_move = false
var can_press = false

var grabOffset = Vector2.ZERO
var mouseP = Vector2()

var panPS = Vector2(-396, 131)
var panPB = Vector2(216, 131)

var height
var peak_y = 0.0
var was_falling = false

var FOLLOW_STRENGTH = 50.0
var DAMPING = 10.0

enum DragTarget { NONE, BOX, BOW, STRING }
var dragging: DragTarget = DragTarget.NONE

var once = true
var c = 0

var blink_tween: Tween
var blink = false
var click = false

var bow_hold = false
var string_hold = false

func _ready() -> void:
	panel.position = panPS
	Signals.change_text.emit("You've got mail !", true, false, true)
	await Signals.text_done
	Signals.change_text.emit("Seems you have gotten a message in the mail. this should be interesting...", false, true, false)
	await Signals.text_done
	Signals.box_drop.emit()

func _physics_process(_delta: float) -> void:
	if can_move and not blink:
		var target: Node = null
		match dragging:
			DragTarget.BOX:
				target = box
			DragTarget.BOW:
				target = bow
			DragTarget.STRING:
				target = string
		if target:
			mouseP = get_global_mouse_position()
			var grabPoint = target.to_global(grabOffset)
			var to_mouse = mouseP - grabPoint
			var force = to_mouse * FOLLOW_STRENGTH - target.linear_velocity * DAMPING
			force = force.limit_length(2000.0)
			target.apply_force(force, grabPoint - target.global_position)

	var is_falling = box.linear_velocity.y > 0
	if is_falling and not was_falling:
		peak_y = box.global_position.y
	was_falling = is_falling

func _on_box_body_entered(body: Node) -> void:
	if body == ground or body == below:
		hits_change(hits)
		if hits == 1 and once:
			Signals.change_text.emit("Try getting it open with your mouse.", true, true, false)
			await Signals.text_done
			once = false
		if hits == 25:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if can_press and hits >= 1:
				dragging = DragTarget.BOX
				grabOffset = box.to_local(get_global_mouse_position())
				can_move = true
			elif bow_hold:
				dragging = DragTarget.BOW
				grabOffset = bow.to_local(get_global_mouse_position())
				can_move = true
			elif string_hold:
				dragging = DragTarget.STRING
				grabOffset = string.to_local(get_global_mouse_position())
				can_move = true
		else:
			can_move = false
			dragging = DragTarget.NONE
	if event is InputEventMouseButton and event.pressed and blink:
		c += 1
		if c == 1:
			stop_blink($box/boxFlash)
			bowMake()
		elif c == 2:
			stop_blink($box/nobow)
			stringMake()

func _on_box_move_mouse_entered() -> void:
	can_press = true

func _on_box_move_mouse_exited() -> void:
	can_press = false

func hits_change(num):
	var fall_height = ground.global_position.y - peak_y
	print(fall_height)
	if fall_height > -800:
		hits += 1
		if num != 1 && num <= cip:
			var text = str(num)
			$CanvasLayer/Panel/numbs.text = text
			var tween = create_tween()
			tween.tween_property(panel, "position", panPB, 0.5)
			await get_tree().create_timer(1).timeout
			var tween2 = create_tween()
			tween2.tween_property(panel, "position", panPS, 0.5)
		if num == cip:
			await get_tree().create_timer(1).timeout
			Signals.change_text.emit("Hmm... Doesnt seem to work...", true, false, false)
			await Signals.text_done
			Signals.change_text.emit("Oh, wait, I have an idea! ", false, true, false)
			await Signals.text_done
			start_blink($box/boxFlash)

func start_blink(asset):
	blink = true
	asset.visible = true
	asset.modulate = co
	blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(asset, "modulate:a", 0, 0.5)
	blink_tween.tween_property(asset, "modulate:a", 1, 0.5)
	await get_tree().create_timer(1).timeout
	click = true

func stop_blink(asset):
	if blink_tween:
		blink_tween.kill()
		blink = false
	asset.modulate.a = 0
	asset.visible = false

func bowMake():
	var bowNode = $bow
	$box/box.play(&"bow")
	await $box/box.animation_finished
	bowNode.position.x = box.position.x - 66
	bowNode.position.y = box.position.y - 226
	bowNode.process_mode = Node.PROCESS_MODE_INHERIT
	bowNode.visible = true
	start_blink($box/nobow)

func stringMake():
	var st = $string
	$box/box.animation = &"box"
	$box/box.play(&"box")
	await $box/box.animation_finished
	st.position.x = box.position.x
	st.position.y = box.position.y - 94
	st.process_mode = Node.PROCESS_MODE_INHERIT
	st.visible = true
	click = false
	blink = false

func _on_bow_up_mouse_entered() -> void:
	bow_hold = true

func _on_bow_up_mouse_exited() -> void:
	bow_hold = false

func _on_string_up_mouse_entered() -> void:
	string_hold = true
	Signals.trash.emit(true)

func _on_string_up_mouse_exited() -> void:
	string_hold = false
	Signals.trash.emit(false)
