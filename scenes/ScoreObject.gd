extends Node2D



func play_score(pos: Vector2, value: int) -> void:
	self.position = pos
	$handle/score.text = "+" + str(value)
	$AnimationPlayer.play("play")
