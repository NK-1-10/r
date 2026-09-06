extends Node2D
@onready var txt = $Text
@onready var box = $box
@onready var boxSprite = $box/box
@onready var mark = $respawn
@onready var ground = $ground
@onready var bow = $box/bow
@onready var string = $box/string
@onready var hover_area = $box/HoverArea

@export var stiffness = 600.0
@export var damping = 25.0
var color = Color('#e45238')

var boxStart = Vector2(1229, -742)
var mouseLocation = Vector2()
var offset = Vector2.ZERO

 # ready and process --------------------------------------------------------------------------------------
func _ready() -> void:
	print("HoverArea exists: ", hover_area != null)
	print("HoverArea children: ", hover_area.get_children())
	for child in hover_area.get_children():
		if child is CollisionShape2D:
			print("shape resource: ", child.shape, " disabled: ", child.disabled, " global pos: ", child.global_position)
	Signals.text_done.connect(txt_done)
	box.body_entered.connect(_on_box_body_entered)
	hover_area.mouse_entered.connect(_on_box_mouse_entered)
	hover_area.mouse_exited.connect(_on_box_mouse_exited)
	box.input_pickable = false
	box.freeze = true
	await get_tree().process_frame
	start()

func _process(delta: float) -> void:
	if holdBox:
		var grab_point = box.to_global(offset)
		var to_target = get_global_mouse_position() - grab_point
		var force = to_target * stiffness - box.linear_velocity * damping
		force = force.limit_length(2000.0)
		box.apply_force(force, grab_point - box.global_position)
	if blink_ready:
		print("mouse global: ", get_global_mouse_position(), " box global: ", box.global_position, " hover_area global: ", hover_area.global_position, " inBox: ", inBox, " paused: ", get_tree().paused)

# ----------------------------------------------no player input
func start():
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
	
# texts  --------------------------------------------------------------------------------------------------------
var can_pick_up = false
func txt_done():
	pass

# box moving -----------------------------------------------------------------------------------------------------
var holdBox = false
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("click detected. blink_ready=", blink_ready, " notClicked=", notClicked, " inBox=", inBox)
		if blink_ready and notClicked and inBox:
			notClicked = false
			print("conditions met, calling Bow()")
			Bow()
		elif can_pick_up and not blink_ready:
			holdBox = true
			offset = box.to_local(get_global_mouse_position())
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		holdBox = false
		box.freeze = false

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
		drops += 1
	if drops == 5:
		next = true
		Signals.change_text.emit("WAIT. I have an idea! Let me just...", true, true, false)
		blink_ready = true
		GoldBlink($box/overlay)

# overlay function ------------------------------------------------------------------------------------------------------
var inBox = false
var blinking = false
var notClicked = true
var blink_ready = false

func GoldBlink(what):
	while blink_ready and notClicked:
		if inBox:
			what.modulate = color                          # <- sets to red
			var tween = get_tree().create_tween()
			tween.tween_property(what, "modulate:a", 0.0, 1) # fade alpha out
			tween.tween_property(what, "modulate:a", 1.0, 1) # fade alpha back in
			await tween.finished
			blinking = true
		else:
			await get_tree().process_frame

func _on_box_mouse_entered() -> void:
	inBox = true
	GoldBlink($box/overlay)
	print("mouse entered box, inBox=true")
func _on_box_mouse_exited() -> void:
	inBox = false
	print("mouse exited box, inBox=false")


func Bow():
	print("Bow() started")
	boxSprite.play(&'bow')
	await boxSprite.animation_finished
	print("bow animation finished")
	bow.process_mode = Node.PROCESS_MODE_ALWAYS
	bow.visible = true
	print("bow visible set to true")
