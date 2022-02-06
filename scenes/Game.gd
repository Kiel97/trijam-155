extends Node2D


var time_left: int = 55 setget set_time_left
var civvies_rescued: int = 0 setget set_civvies_rescued

onready var score = $CanvasLayer/UI/Civvies
onready var time = $CanvasLayer/UI/Time

onready var post_game_board = $SummaryLayer/PostGameBoard

onready var civvie_scene = preload("res://scenes/Civvie.tscn")
onready var score_scene = preload("res://scenes/ScoreObject.tscn")

func _ready() -> void:
	randomize()
	post_game_board.visible = false
	$Timer.start()
	$CivvieSpawnTimer.start()
	$FireSpawnTimer.start()
	call_deferred("init_map")

func init_map() -> void:
	for window in $Windows.get_children():
		window.connect("spawned_civvie", self, "on_spawned_civvie")
		window.connect("rescued_civvie_from_window", self, "_on_Player_rescued_civvie_2")
	
	select_windows()

func _on_Timer_timeout() -> void:
	self.time_left -= 1

func set_time_left(value: int) -> void:
	time_left = value
	time.text = str(value).pad_zeros(2)
	
	if time_left == 0:
		$CivvieSpawnTimer.stop()
		$FireSpawnTimer.stop()
	elif time_left == -1:
		$Timer.stop()
		$Jumper.queue_free()
		$Player.can_move = false
		show_win_board()

func set_civvies_rescued(value) -> void:
	civvies_rescued = value
	score.text = str(value).pad_zeros(2)

func select_windows() -> void:
	var FIRE = 3
	var CIVVIE = 1
	
	var windows_in_building = $Windows.get_children()
	var selected = 0
	
	while selected < FIRE:
		var window = windows_in_building[randi() % windows_in_building.size()]
		if window.on_fire == false:
			window.on_fire = true
			selected += 1
			windows_in_building.erase(window)
	
	selected = 0
	
	while selected < CIVVIE:
		var window = windows_in_building[randi() % windows_in_building.size()]
		if can_spawn_civvie(window):
			window.civvie = true
			selected += 1
			windows_in_building.erase(window)

func on_spawned_civvie(pos: Vector2) -> void:
	var civvie = civvie_scene.instance()
	civvie.position = pos
	civvie.connect("rescued", self, "_on_Player_rescued_civvie_3")
	add_child(civvie)

func _on_Player_rescued_civvie() -> void:
	self.civvies_rescued += 1
	spawn_scoreobject(1)
	$CivvieSound1.pitch_scale = rand_range(0.8, 1.2)
	$CivvieSound1.play()

func _on_Player_rescued_civvie_2() -> void:
	self.civvies_rescued += 2
	spawn_scoreobject(2)
	$CivvieSound2.pitch_scale = rand_range(0.8, 1.2)
	$CivvieSound2.play()

func _on_Player_rescued_civvie_3() -> void:
	self.civvies_rescued += 3
	spawn_scoreobject(3)
	$CivvieSound3.pitch_scale = rand_range(0.8, 1.2)
	$CivvieSound3.play()

func spawn_scoreobject(score: int) -> void:
	var scoreobject = score_scene.instance()
	add_child(scoreobject)
	scoreobject.play_score(Vector2(218, 20), score)

func _on_CivvieSpawnTimer_timeout() -> void:
	var spawned = false
	var windows_in_building = $Windows.get_children()
	var tries = 0
	
	while not spawned:
		var window = windows_in_building[randi() % windows_in_building.size()]
		if can_spawn_civvie(window):
			window.civvie = true
			spawned = true
		elif tries >= 10 and window.civvie == true and window.on_fire == false:
			window.eject_civvie()
			window.civvie = true
			spawned = true
		tries += 1

func can_spawn_civvie(window) -> bool:
	return window.on_fire == false and window.civvie == false

func _on_FireSpawnTimer_timeout() -> void:
	var spawned = false
	var windows_in_building = $Windows.get_children()
	
	while not spawned:
		var window = windows_in_building[randi() % windows_in_building.size()]
		if window.on_fire == false:
			if window.civvie == true:
				window.eject_civvie()
			window.on_fire = true
			spawned = true

func _on_Jumper_dead() -> void:
	for window in $Windows.get_children():
		window.civvie = false
	$Timer.stop()
	$CivvieSpawnTimer.stop()
	$FireSpawnTimer.stop()
	show_lose_board()

func show_win_board():
	$BGM.stop()
	$WinSound.play()
	$CanvasLayer/UI.visible = false
	post_game_board.visible = true
	$SummaryLayer/PostGameBoard/MarginContainer/VBoxContainer/Title.text = "You win"
	$SummaryLayer/PostGameBoard/MarginContainer/VBoxContainer/Stats.text = "Score: " + str(civvies_rescued).pad_zeros(3)

func show_lose_board():
	$BGM.stop()
	$LoseSound.play()
	$CanvasLayer/UI.visible = false
	post_game_board.visible = true
	$SummaryLayer/PostGameBoard/MarginContainer/VBoxContainer/Title.text = "You lose"
	$SummaryLayer/PostGameBoard/MarginContainer/VBoxContainer/Stats.text = "Score: " + str(civvies_rescued).pad_zeros(3) + "\n Time left: " + str(time_left).pad_zeros(3)

func _on_Button_pressed() -> void:
	get_tree().reload_current_scene()
