extends ColorRect

enum Dir { N, S, E, W }
@export var dir: int = Dir.N

# --- Color Palette (Temporal Glitch) ---
@export var idle_color: Color    = Color(0.12, 0.12, 0.12)   # near-black
@export var prompt_color: Color  = Color(0.20, 0.80, 0.70)   # teal (what to hit)
@export var pressed_color: Color = Color(0.40, 0.90, 0.85)   # lighter teal
@export var correct_color: Color = Color(0.40, 0.90, 0.40)   # mint green
@export var wrong_color: Color   = Color(0.90, 0.25, 0.25)   # red

var is_flashing: bool = false
var is_prompt: bool = false


func _ready() -> void:
	color = idle_color


# Called when this square is the active target
func set_prompt(active: bool) -> void:
	is_prompt = active
	if is_flashing:
		return
	color = prompt_color if is_prompt else idle_color


# Called on key down / key up
func set_pressed(is_pressed: bool) -> void:
	if is_flashing:
		return

	if is_prompt and not is_pressed:
		# keep teal if this is the active prompt
		color = prompt_color
	else:
		color = pressed_color if is_pressed else (prompt_color if is_prompt else idle_color)


func flash_correct() -> void:
	is_flashing = true
	color = correct_color
	await get_tree().create_timer(0.12).timeout
	is_flashing = false
	color = prompt_color if is_prompt else idle_color


func flash_wrong() -> void:
	is_flashing = true
	color = wrong_color
	await get_tree().create_timer(0.12).timeout
	is_flashing = false
	color = prompt_color if is_prompt else idle_color
