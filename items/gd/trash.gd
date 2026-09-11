extends AnimatedSprite2D

var isIn = false
@onready var trash = $"."

var trashS = Vector2(3487, 250)
var trashE = Vector2(2422, 250)

func _ready() -> void:
	trash.position = trashS
	trash.animation = &"normal"
	Signals.trash.connect(on_trash)

func _on_get_body_entered(body: Node2D) -> void:
	if body.is_in_group('throwables'):
		isIn = true
		trash.animation = &"normal"
		trash.play()

func _on_get_body_exited(body: Node2D) -> void:
	isIn = false
	trash.animation = &"backward"
	trash.play()

func on_trash(what):
	var tween = create_tween()
	if what:
		tween.tween_property(trash, "position", trashE, 0.7)
	else:
		tween.tween_property(trash, "position", trashS, 0.7)
