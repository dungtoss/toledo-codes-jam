extends Node

enum Dir { N, S, E, W }

@onready var timer_label: Label = $"../CenterCat/TimerLabel"
@onready var game_timer: Timer = $GameTimer


@onready var score_label: Label = $"../ScoreLabel"

@onready var tN = $"../TargetN"
@onready var tS = $"../TargetS"
@onready var tE = $"../TargetE"
@onready var tW = $"../TargetW"

var score: int = 0
var current_dir: int = Dir.N
var time_left: int = 60

func _ready() -> void:
	randomize()
	time_left = 60
	timer_label.text = str(time_left)

	game_timer.timeout.connect(_on_game_timer_timeout)
	game_timer.start()

	await get_tree().process_frame
	next_round()
	update_ui()

func _on_game_timer_timeout() -> void:
	time_left -= 1
	timer_label.text = str(time_left)

	if time_left <= 0:
		game_timer.stop()
		timer_label.text = "0"
		print("GAME OVER") # we’ll replace this later

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		var d: int = dir_from_key(event.keycode)
		if d == -1:
			return

		# Visual feedback (pressed/unpressed)
		set_target_pressed(d, event.pressed)

		# Only score/check on key DOWN
		if event.pressed:
			check_answer(d)


func dir_from_key(keycode: int) -> int:
	match keycode:
		KEY_UP: return Dir.N
		KEY_DOWN: return Dir.S
		KEY_RIGHT: return Dir.E
		KEY_LEFT: return Dir.W
		_: return -1


func set_target_pressed(d: int, is_pressed: bool) -> void:
	match d:
		Dir.N: tN.set_pressed(is_pressed)
		Dir.S: tS.set_pressed(is_pressed)
		Dir.E: tE.set_pressed(is_pressed)
		Dir.W: tW.set_pressed(is_pressed)

func next_round() -> void:
	# turn off all prompts first
	tN.set_prompt(false)
	tS.set_prompt(false)
	tE.set_prompt(false)
	tW.set_prompt(false)

	# pick new active direction
	current_dir = randi() % 4

	# activate (green) the chosen target
	match current_dir:
		Dir.N: tN.set_prompt(true)
		Dir.S: tS.set_prompt(true)
		Dir.E: tE.set_prompt(true)
		Dir.W: tW.set_prompt(true)

func dir_to_arrow(d: int) -> String:
	match d:
		Dir.N: return "↑"
		Dir.S: return "↓"
		Dir.E: return "→"
		Dir.W: return "←"
		_: return "?"


func check_answer(pressed_dir: int) -> void:
	var correct: bool = (pressed_dir == current_dir)

	if correct:
		score += 1
		flash_target(pressed_dir, true)
	else:
		score -= 1
		flash_target(pressed_dir, false)

	update_ui()
	next_round()


func flash_target(d: int, ok: bool) -> void:
	match d:
		Dir.N:
			if ok: tN.flash_correct()
			else: tN.flash_wrong()
		Dir.S:
			if ok: tS.flash_correct()
			else: tS.flash_wrong()
		Dir.E:
			if ok: tE.flash_correct()
			else: tE.flash_wrong()
		Dir.W:
			if ok: tW.flash_correct()
			else: tW.flash_wrong()


func update_ui() -> void:
	score_label.text = "Score: %d" % score
