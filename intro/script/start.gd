extends Node2D
@onready var txt = $Text
@onready var box = $box
@onready var info = $explain/Panel
@onready var mark = $respawn

var panelStart = Vector2(87.0, 1473.0)
var panelEnd = Vector2(87.0, 218.0)
var boxStart = Vector2(1229, -742)
var mouseLocation = Vector2()

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

 # ready and process --------------------------------------------------------------------------------------
func _ready() -> void:
	box.freeze = true
	await get_tree().create_timer(1).timeout
	Signals.text_toggle.emit("up")
	info.position = panelStart
	Signals.Intro_finnished.connect(on_intro_finnished)
	box.position = boxStart
	Signals.change_text.emit(intro[n], true)

func _process(delta: float) -> void:
	if holdBox:
		box.position = get_global_mouse_position()
	
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and waitingForClick:
			holdBox = true
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
