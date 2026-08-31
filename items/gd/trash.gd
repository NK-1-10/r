extends AnimatedSprite2D
var isIn = false
@onready var trash = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trash.animation = &"normal"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isIn:
		trash.play()
	else:
		var o = trash.frame
		trash.animation = &"backward"
		trash.frame = 9-o #9 being the ammount of frames
		trash.play()


func _on_get_body_entered(body: Node2D) -> void:
	if body.is_in_group('throwables'):
		isIn = true

func _on_get_body_exited(body: Node2D) -> void:
	isIn = false
