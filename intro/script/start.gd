extends Node2D

@onready var box = $box
@onready var ground = $walls/ground
@onready var below = $walls/once
@onready var panel = $CanvasLayer/Panel

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

func _ready() -> void:
	panel.position = panPS
	Signals.change_text.emit("You've got mail !", true, false, true) #(what_text, first, end, header)
	await Signals.text_done
	Signals.change_text.emit("Seems you have gotten a message in the mail. this should be interesting...", false, true, false) #(what_text, first, end, header)
	await Signals.text_done
	Signals.box_drop.emit()

func _physics_process(_delta: float) -> void:
	if can_move and not blink:
		mouseP = get_global_mouse_position()
		var grabPoint = box.to_global(grabOffset)
		var to_mouse = mouseP - grabPoint
		var force = to_mouse * FOLLOW_STRENGTH - box.linear_velocity * DAMPING
		force = force.limit_length(2000.0)
		box.apply_force(force, grabPoint - box.global_position)
		
	var is_falling = box.linear_velocity.y > 0
	if is_falling and not was_falling:
		peak_y = box.global_position.y
	was_falling = is_falling

var once = true
func _on_box_body_entered(body: Node) -> void:
	if body == ground or body == below:
		hits_change(hits)
		if hits == 1 and once:
			Signals.change_text.emit("Try getting it open with your mouse.", true, true, false) #(what_text, first, end, header)
			await Signals.text_done
			once = false
		if hits ==25:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if can_press and hits >= 1:
				grabOffset = box.to_local(get_global_mouse_position())
				can_move = true
		else:
			can_move = false
	if event is InputEventMouseButton and blink:
		stop_blink($box/boxFlash)
		bow()

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
			tween.tween_property(panel, "position", panPB,0.5)
			await get_tree().create_timer(1).timeout
			var tween2 = create_tween()
			tween2.tween_property(panel, "position", panPS, 0.5)
		if num == cip:
			await get_tree().create_timer(1).timeout
			Signals.change_text.emit("Hmm... Doesnt seem to work...", true, false, false) #(what_text, first, end, header)
			await Signals.text_done
			Signals.change_text.emit("Oh, wait, I have an idea! ", false, true, false) #(what_text, first, end, header)
			await Signals.text_done
			start_blink($box/boxFlash)

var blink_tween: Tween
var blink = false
var click = false

func start_blink(asset):
	blink = true
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
	
func bow():
	$box/box.play(&"bow")
	await $box/box.animation_finished
	$bow.position.x = box.position.x - 66
	$bow.position.y = box.position.y - 226
	$bow.process_mode = Node.PROCESS_MODE_INHERIT
	$bow.visible = true
