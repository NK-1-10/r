extends CanvasLayer
@onready var panel = $Panel
@onready var h1 = $Panel/Heading
@onready var txt = $Panel/Text
var down = Vector2(0, 1384)
var up = Vector2(0, 801)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.top_level = true
	panel.position = down
	print("CanvasLayer _ready called, connections before: ", Signals.change_text.get_connections().size())
	if not Signals.change_text.is_connected(on_change_text):
		Signals.change_text.connect(on_change_text)
	print("connections after: ", Signals.change_text.get_connections().size())


func on_change_text(which, first, end, header):
	Global.typing = true
	if first:
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(panel, "position", up, 0.5)
		await tween.finished
	if header: 
		await Global.Typewriter(which, h1, false)
	else: 
		await Global.Typewriter(which, txt, true)
	if end:
		await get_tree().create_timer(0.5).timeout
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(panel, "position", down, 0.5)
		await tween.finished
	Global.typing = false
	Signals.text_done.emit()
