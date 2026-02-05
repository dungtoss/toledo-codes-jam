extends Node

enum Dir { N, S, E, W }

@onready var timer_label: Label = $"../CenterCat/TimerLabel"
@onready var score_label: Label = $"../ScoreLabel"

@onready var game_timer: Timer = $GameTimer
@onready var phase_timer: Timer = $PhaseTimer

@onready var tN = $"../TargetN"
@onready var tS = $"../TargetS"
@onready var tE = $"../TargetE"
@onready var tW = $"../TargetW"

# ----------------------------
# GAME STATE
# ----------------------------
var score: int = 0
var time_left: int = 60
var game_over := false

# ----------------------------
# PHASE SYSTEM (6 sec total)
# ----------------------------
const PHASE_COUNT := 3
var phase_index: int = 0
var phase_duration: float = 2.0  # 2 sec each phase => 6 sec total
var current_dir: int = Dir.N
var last_dir: int = -1

var idle_color := Color(0.12, 0.12, 0.12)  # dark/idle for inactive

# Phase 1, 2, 3 colors (index 0..2)
var phase_colors := [
	Color(0.95, 0.55, 0.15), # Phase 1 (orange)
	Color(0.25, 0.60, 1.00), # Phase 2 (blue)
	Color(0.40, 0.90, 0.40), # Phase 3 (green)
]

# Prevent double-advance (timer + key press same frame)
var sequence_advancing := false

func _ready() -> void:
	randomize()

	# --- 60 second game countdown timer ---
	time_left = 60
	timer_label.text = str(time_left)
	game_timer.one_shot = false
	game_timer.timeout.connect(_on_game_timer_timeout)
	game_timer.start()

	# --- Phase timer (ticks every 2 seconds) ---
	phase_timer.one_shot = false
	phase_timer.wait_time = phase_duration
	phase_timer.timeout.connect(_on_phase_timer_timeout)

	# Start the first direction + phase sequence
	start_new_sequence()

	update_ui()


# ----------------------------
# PHASE SEQUENCE LOOP
# ----------------------------
func start_new_sequence() -> void:
	sequence_advancing = false

	# reset all visuals to idle
	set_all_targets_color(idle_color)

	# pick new active direction
	last_dir = current_dir

	while true:
		current_dir = randi() % 4
		if current_dir != last_dir:
			break
	
	phase_index = 0

	# show which direction is active via your prompt system (if you have it)
	if tN.has_method("set_prompt"):
		tN.set_prompt(false)
		tS.set_prompt(false)
		tE.set_prompt(false)
		tW.set_prompt(false)

		match current_dir:
			Dir.N: tN.set_prompt(true)
			Dir.S: tS.set_prompt(true)
			Dir.E: tE.set_prompt(true)
			Dir.W: tW.set_prompt(true)

	# apply phase 1 color immediately
	apply_active_phase_color()

	# start ticking phases
	phase_timer.start()


func _on_phase_timer_timeout() -> void:
	if game_over:
		return
	if sequence_advancing:
		return

	phase_index += 1

	# finished 3 phases -> pick new direction and repeat (only if player didn't clear it)
	if phase_index >= PHASE_COUNT:
		sequence_advancing = true
		start_new_sequence()
		return

	apply_active_phase_color()


func apply_active_phase_color() -> void:
	# keep others idle
	set_all_targets_color(idle_color)

	# phase_index is 0..2
	var c: Color = phase_colors[phase_index]

	match current_dir:
		Dir.N: tN.set_base_color(c)
		Dir.S: tS.set_base_color(c)
		Dir.E: tE.set_base_color(c)
		Dir.W: tW.set_base_color(c)


func set_all_targets_color(c: Color) -> void:
	tN.set_base_color(c)
	tS.set_base_color(c)
	tE.set_base_color(c)
	tW.set_base_color(c)


# ----------------------------
# 60s COUNTDOWN
# ----------------------------
func _on_game_timer_timeout() -> void:
	if game_over:
		return

	time_left -= 1
	timer_label.text = str(time_left)

	if time_left <= 0:
		game_over = true

		game_timer.stop()
		phase_timer.stop()

		timer_label.text = "0"

		# freeze visuals
		set_all_targets_color(idle_color)

		print("GAME OVER")



# ----------------------------
# INPUT + SCORING
# Correct input: immediately move to next direction
# Wrong input: lose point and keep the same direction/phase running
# ----------------------------
func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return

	if event is InputEventKey and not event.echo and event.pressed:
		var d: int = dir_from_key(event.keycode)
		if d == -1:
			return
		check_answer(d)


func dir_from_key(keycode: int) -> int:
	match keycode:
		KEY_UP: return Dir.N
		KEY_DOWN: return Dir.S
		KEY_RIGHT: return Dir.E
		KEY_LEFT: return Dir.W
		_: return -1


func check_answer(pressed_dir: int) -> void:
	var correct: bool = (pressed_dir == current_dir)

	if correct:
		score += 1
		update_ui()

		# cancel remaining phases + advance immediately
		sequence_advancing = true
		phase_timer.stop()

		# optional tiny feedback flash (remove these 2 lines if you want instant)
		flash_target(pressed_dir, true)
		await get_tree().create_timer(0.08).timeout

		start_new_sequence()
		return
	else:
		score -= 1
		flash_target(pressed_dir, false)
		update_ui()


# optional: if your Target.gd has flash methods, this will use them.
# If not, it's safe (it checks has_method).
func flash_target(d: int, ok: bool) -> void:
	var target
	match d:
		Dir.N: target = tN
		Dir.S: target = tS
		Dir.E: target = tE
		Dir.W: target = tW

	if target == null:
		return

	if ok and target.has_method("flash_correct"):
		target.flash_correct()
	elif (not ok) and target.has_method("flash_wrong"):
		target.flash_wrong()

	# restore phase color after flash
	call_deferred("apply_active_phase_color")


func update_ui() -> void:
	score_label.text = "Score: %d" % score
