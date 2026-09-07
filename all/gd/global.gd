extends Node

var result = ""
var typetime = 0.05
var typestop = 0.7
var time = 0.03
var typing = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func Typewriter(Text , Place, Paused):
	await get_tree().create_timer(0.5).timeout
	if Text == "":
		Place.set_text("") 
		return
	if Paused:
		await get_tree().create_timer(0.5).timeout
	for n in Text.length():
		var now = Text[n]
		if Text[n] == "." or Text[n] == "?" or Text[n] == "!": time = typestop
		else:  time = typetime
		result += now
		Place.set_text(result)  
		await get_tree().create_timer(time).timeout
	await get_tree().create_timer(1).timeout
	result = ""
	Place.set_text(result) 

func _process(delta: float) -> void:
	if typing: get_tree().paused = true 
	else: get_tree().paused = false
