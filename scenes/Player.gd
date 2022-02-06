extends Area2D

signal rescued_civvie


const SPRITE_OFFSET = 32

var can_move: bool = true setget set_can_move


func _process(delta: float) -> void:
	if can_move:
		position.x = clamp(get_global_mouse_position().x, 0+SPRITE_OFFSET, 256-SPRITE_OFFSET)

func _on_Player_body_entered(body: Node) -> void:
	if can_move:
		if body.is_in_group("jumper"):
			body.jump()
			$AnimationPlayer.play("trigger")
			$Jump.pitch_scale = rand_range(0.7, 1.3)
			$Jump.play()
		elif body.is_in_group("civvie"):
			emit_signal("rescued_civvie")
			body.queue_free()

func _on_Jumper_dead() -> void:
	self.can_move = false

func set_can_move(value: bool) -> void:
	set_process(value)
	set_physics_process(value)
