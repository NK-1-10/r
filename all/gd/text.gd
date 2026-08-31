extends  CanvasLayer

@onready var panel = $Panel
@onready var h1 = $Panel/Heading
@onready var txt = $Panel/Text
var string = ""
var c = 1

var down = Vector2(0, 1384)
var up = Vector2(0, 801)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.position = down
	Signals.change_text.connect(on_change_text)
	Signals.text_toggle.connect(on_change)

func on_change_text(which):
	await Global.Typewriter(which.header, h1, false)
	await Global.Typewriter(which.text, txt, true)
	# await get_tree().create_timer(2.0).timeout
	Signals.Intro_finnished.emit()
	c += 1

func on_change(where):
	if where == "up":
		var tween = get_tree().create_tween()
		tween.tween_property(panel, "position", up, 0.5)
	elif where == "down":
		var tween = get_tree().create_tween()
		tween.tween_property(panel, "position", down, 0.5)
