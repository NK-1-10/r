extends Node2D
@onready var mark = $respawn


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_out_body_exited(body: Node2D) -> void:
	body.call_deferred("set_global_position", mark.global_position)
