extends Node2D
@onready var txt = $Text
@onready var box = $box
@onready var boxSprite = $box/box
@onready var mark = $respawn
@onready var ground = $ground
@onready var bow = $box/bow
@onready var string = $box/string
@onready var hover_area = $box/HoverArea
@onready var overlay = $box/box/Sprite2D

@export var stiffness = 600.0
@export var damping = 25.0
var color = Color('#e45238')

var boxStart = Vector2(1229, -742)
var mouseLocation = Vector2()
var offset = Vector2.ZERO
var holdBox = false
var inBoxArea = false

 # ready and process --------------------------------------------------------------------------------------
func _ready() -> void:
	box.body_entered.connect(_on_box_body_entered)
	box.input_pickable = false
	box.freeze = true
	await get_tree().process_frame
	start()

func _process(delta: float) -> void:
	if Engine.get_process_frames() % 60 == 0:
		print("box pos: ", box.global_position, " mouse: ", get_global_mouse_position())
	if holdBox:
		var grab_point = box.to_global(offset)
		var to_target = get_global_mouse_position() - grab_point
		var force = to_target * stiffness - box.linear_velocity * damping
		force = force.limit_length(2000.0)
		box.apply_force(force, grab_point - box.global_position)

# ----------------------------------------------no player input
func start():
	print('start is start')
	box.position = boxStart
	Signals.change_text.emit("You've got mail!", true, false, true)
	await Signals.text_done
	await get_tree().process_frame
	Signals.change_text.emit("Hmm... seems you have gotten a package in the mail. Whatever could this stuff be?", false, false, false)
	await Signals.text_done
	box.freeze = false
	await get_tree().process_frame
	Signals.change_text.emit("Lets try this -> Hover over the box and try oving it around", false, true, false)
	can_pick_up = true
	print('can pick up is enabled true')
	
# texts  --------------------------------------------------------------------------------------------------------
var can_pick_up = false
# box moving -----------------------------------------------------------------------------------------------------

# throw out ------------------------------------------------------------------------------------------------------
var firstTime = true
func _on_out_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		if firstTime:
			Signals.change_text.emit("Really? Really? We throwing it out? geez, what a pain...", true, true, false)
			firstTime = false
		body.call_deferred("set_global_position", mark.global_position)
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
	else:
		body.position = mark.position

# after pick up box ------------------------------------------------------------------------------------------------------
var drops = 0
var next = false
func _on_box_body_entered(body: Node) -> void:
	if body == ground and can_pick_up:
		print('meet the ground...', drops)
		drops += 1
	if drops == 20:
		var n = true
		next = true
		if n:
			n = false
			Signals.change_text.emit("WAIT. I have an idea! Let me just...", true, true, false)
			await Signals.text_done
			await get_tree().process_frame
			Signals.change_text.emit("$env:enable_open = 'True' ", true, true, false)
			await Signals.text_done
			await get_tree().process_frame
		fade_loop()
		#can_press = true
		

# overlay function ------------------------------------------------------------------------------------------------------

var fading = false

func fade_loop():
	overlay.modulate = color
	fading = true
	while fading:
		var tween = create_tween()
		tween.tween_property(overlay, "modulate:a", 1.0, 1.0)
		await tween.finished
		if not fading:
			overlay.modulate = Color(color.r, color.g, color.b, 0.0)
			break
		var tween2 = create_tween()
		tween2.tween_property(overlay, "modulate:a", 0.0, 1.0)
		await tween2.finished

func Bow():
	boxSprite.play(&'bow')
	await boxSprite.animation_finished
	bow.process_mode = Node.PROCESS_MODE_ALWAYS
	bow.visible = true


func _on_hover_area_mouse_entered() -> void:
	print('trying to enter area...')
	if can_pick_up:
		inBoxArea = true
		print ('in box area')

func _on_hover_area_mouse_exited() -> void:
	print('trying to leaev area...')
	inBoxArea = false
	print ('not in box area')
