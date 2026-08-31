extends Node2D
var mouse = false
@onready var exp = $RigidBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse:
		pass
	else:
		pass


func _on_rigid_body_2d_mouse_entered() -> void:
	mouse = true

func _on_rigid_body_2d_mouse_exited() -> void:
	mouse = false
