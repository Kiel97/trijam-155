extends Area2D

signal spawned_civvie(window)
signal rescued_civvie_from_window


export var on_fire: bool = false setget set_on_fire, get_on_fire
export var civvie: bool = false setget set_civvie, get_civvie

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_on_fire(value: bool) -> void:
	on_fire = value
	if value:
		$AnimationPlayer.play("on_fire")
	else:
		if not civvie:
			$AnimationPlayer.play("RESET")

func set_civvie(value: bool) -> void:
	civvie = value
	if value:
		$AnimationPlayer.play("civvie")
		$CivvieTimer.start()
	else:
		$CivvieTimer.stop()
		if not on_fire:
			$AnimationPlayer.play("RESET")

func _on_CivvieTimer_timeout() -> void:
	eject_civvie()

func get_on_fire() -> bool:
	return on_fire

func get_civvie() -> bool:
	return civvie

func _on_Window_body_entered(body: Node) -> void:
	if civvie and body.is_in_group("jumper"):
		emit_signal("rescued_civvie_from_window")
		self.civvie = false

func eject_civvie() -> void:
	self.civvie = false
	emit_signal("spawned_civvie", self.position)
