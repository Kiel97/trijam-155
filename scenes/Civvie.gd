extends KinematicBody2D

signal rescued

var gravity = 100

var velocity = Vector2.ZERO

func _ready() -> void:
	randomize()
	_jump_to_side()
	
	$Fall.pitch_scale = rand_range(0.8, 1.2)
	$Fall.play()
	$AnimationPlayer.play("jumped")

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		die()

func _jump_to_side():
	var x_side = 0
	var x_randf = randf()
	if x_randf < 0.45:
		x_side = -10
	elif x_randf < 0.9:
		x_side = 10
		
	velocity.x += x_side

func die():
	set_physics_process(false)
	$Sprite.visible = false
	$Die.pitch_scale = rand_range(0.8, 1.2)
	$Die.play()
	yield($Die, "finished")
	self.queue_free()

func _on_RescueArea_body_entered(body: Node) -> void:
	if body.is_in_group("jumper"):
		emit_signal("rescued")
		self.queue_free()
