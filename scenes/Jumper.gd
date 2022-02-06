extends KinematicBody2D

signal dead

const MAX_X_VELOCITY = 150

var speed = 12
var jump_speed = -180
var gravity = 100

var velocity = Vector2.ZERO
var facing = 120

var can_move: bool = true setget set_can_move

func _ready() -> void:
	facing = speed if randf() > 0.5 else -speed

func _physics_process(delta):
	velocity.x += facing * delta
	velocity.x = clamp(velocity.x, -MAX_X_VELOCITY, MAX_X_VELOCITY)
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		die()

func flip_side() -> void:
	facing *= -1
	velocity.x *= -1

func jump():
	velocity.y = jump_speed

func die():
	emit_signal("dead")
	self.can_move = false
	$Die.play()
	yield($Die, "finished")
	self.queue_free()

func set_can_move(value: bool) -> void:
	$Sprite.flip_v = true
	set_process(value)
	set_physics_process(value)
