extends Node

var result = ""
var typetime = 0.05
var typestop = 0.7
var time = 0.03
var typing = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func Typewriter(Text , Place, Paused):
	if Paused:
		await get_tree().create_timer(2).timeout
	for n in Text.length():
		typing = true
		var now = Text[n]
		if Text[n] == "." or Text[n] == "?" or Text[n] == "!": time = typestop
		else:  time = typetime
		result += now
		Place.set_text(result)
		await get_tree().create_timer(time).timeout
	result = ""
	typing = false

func _process(delta: float) -> void:
	if typing: get_tree().paused = true 
	else: get_tree().paused = false
