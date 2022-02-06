extends Area2D


func _on_Border_body_entered(body: Node) -> void:
	if body.is_in_group("jumper"):
		body.flip_side()
