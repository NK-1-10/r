extends Node2D
@onready var txt = $Text
@onready var box = $box
@onready var info = $explain/Panel
@onready var mark = $respawn
@onready var ground = $ground

@export var stiffness = 600.0
@export var damping = 25.0
var color = Color('#e45238')


var panelStart = Vector2(87.0, 1473.0)
var panelEnd = Vector2(87.0, 218.0)
var boxStart = Vector2(1229, -742)
var mouseLocation = Vector2()
var offset = Vector2.ZERO
var startBow = false ; 

var intro = {
	1 :{
		"header": "You've got mail!",
		"text": "Hmm... seems you have gotten a package in the mail. Whatever could this stuff be?"
	}
}
var n = 1
var waitingForClick = false
var click = 0
var holdBox = false;
var first = true;
var drops = 0
var waitForDrop = false

 # ready and process --------------------------------------------------------------------------------------
func _ready() -> void:
	box.body_entered.connect(_on_box_body_entered)
	box.freeze = true
	await get_tree().create_timer(1).timeout
	Signals.text_toggle.emit("up")
	info.position = panelStart
	Signals.Intro_finnished.connect(on_intro_finnished)
	box.position = boxStart
	Signals.change_text.emit(intro[n], true)

func _process(delta: float) -> void:
	if holdBox:
		if first:
			phase2()
			first = false
		var grab_point = box.to_global(offset)
		var to_target = get_global_mouse_position() - grab_point
		var force = to_target * stiffness - box.linear_velocity * damping
		force = force.limit_length(2000.0)  # tune this cap
		box.apply_force(force, grab_point - box.global_position)
	if startBow:
		waitingForClick = false
		Bow()
	
# intro --------------------------------------------------------------------------------------------------------

func on_intro_finnished():
	Signals.text_toggle.emit("down")
	await get_tree().create_timer(1).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(info, "position", panelEnd, 1.5)
	await get_tree().create_timer(1.5).timeout
	await Global.Typewriter("Welcome!", $explain/Panel/header, false)
	await Global.Typewriter("Lets start. You have a package and you probably want to get it open, right? Well, try using your mouse to do so.", $explain/Panel/tut, true)
	waitingForClick = true
	n += 1

# box moving -----------------------------------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and waitingForClick:
		if click == 0 and Global.typing == false:
			await Global.Typewriter("Great!", $explain/Panel/header, false)
			await Global.Typewriter("Take your mouse and grab the package!", $explain/Panel/tut, false)
			click = click + 1
		if click == 1 and Global.typing == false:
			await Global.Typewriter("Hold up. Let me just..", $explain/Panel/tut, false)
			click += 1
			startBow = true
		if click == 2 and Global.typing == false:
			await Global.Typewriter("Hold up. Let me just..", $explain/Panel/tut, false)
			click += 1
			startBow = true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and waitingForClick:
			holdBox = true
			offset = box.to_local(get_global_mouse_position())
		else:
			holdBox = false
			box.freeze = false

# throw out ------------------------------------------------------------------------------------------------------

func _on_out_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		body.call_deferred("set_global_position", mark.global_position)
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
	else:
		body.position = mark.position

# after pick up box ------------------------------------------------------------------------------------------------------

func phase2():
	await Global.Typewriter("Hmm...", $explain/Panel/header, false)
	await Global.Typewriter("Seems rather sterdy...", $explain/Panel/tut, true)
	waitForDrop = true

func _on_box_body_entered(body: Node) -> void:
	if body == ground and waitForDrop:
		drops += 1
	if drops == 15:
		startBow = true

func Bow():
	startBow = false
	await Global.Typewriter("...", $explain/Panel/header, false)
	await Global.Typewriter("Have you tried just...clicking on it?", $explain/Panel/tut, true)
	GoldBlink($box/overlay)
	waitingForClick = true

# overlay function ------------------------------------------------------------------------------------------------------
var inBox = false
var notClicked = true
func GoldBlink(what):
	while inBox and notClicked:
		what.color = color
		var tween2 = get_tree().create_tween()
		tween2.tween_method(what,'opasity', 100, 1)
		var tween = get_tree().create_tween()
		tween.tween_method(what, "opasity", 0, 1)

func _on_box_mouse_entered() -> void:
	inBox = true

func _on_box_mouse_exited() -> void:
	inBox = false
