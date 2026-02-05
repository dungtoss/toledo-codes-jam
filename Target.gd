extends ColorRect

enum Dir { N, S, E, W }
@export var dir: int = Dir.N

# Overlay colors (only used temporarily)
@export var pressed_color: Color = Color(0.40, 0.90, 0.85)   # lighter teal
@export var correct_color: Color = Color(0.40, 0.90, 0.40)   # mint green
@export var wrong_color: Color   = Color(0.90, 0.25, 0.25)   # red

var is_flashing: bool = false
var is_pressed: bool = false

# GameManager controls this (phase color or idle color)
var base_color: Color = Color(0.12, 0.12, 0.12)

func _ready() -> void:
	_apply_color()

# GameManager calls this whenever phase changes / idle resets
func set_base_color(c: Color) -> void:
	base_color = c
	_apply_color()

# Optional: keep for compatibility, but it no longer changes color
func set_prompt(active: bool) -> void:
	# prompt is now handled by base_color (phase colors)
	pass

func set_pressed(pressed: bool) -> void:
	is_pressed = pressed
	_apply_color()

func flash_correct() -> void:
	is_flashing = true
	color = correct_color
	await get_tree().create_timer(0.12).timeout
	is_flashing = false
	_apply_color()

func flash_wrong() -> void:
	is_flashing = true
	color = wrong_color
	await get_tree().create_timer(0.12).timeout
	is_flashing = false
	_apply_color()

func _apply_color() -> void:
	if is_flashing:
		return
	if is_pressed:
		color = pressed_color
	else:
		color = base_color
