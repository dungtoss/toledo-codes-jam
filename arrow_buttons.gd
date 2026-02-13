extends TextureButton

@onready var upArrowButton = $"../UpArrowButton"
@onready var downArrowButton = $"../DownArrowButton"
@onready var leftArrowButton = $"../LeftArrowButton"
@onready var rightArrowButton = $"../RightArrowButton"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _input(event):
	#checks if the input is an arrow key and then calls sprite changing
	#function if it is (there HAS to be a cleaner way to this)
	if event is InputEventKey:
		match event.keycode:
			#used a match statement to avoid errors when accessing the
			#dictionary in set_arrow_button_pressed_state() 
			KEY_UP: set_arrow_button_pressed_state(event.keycode, event.pressed)
			KEY_DOWN: set_arrow_button_pressed_state(event.keycode, event.pressed)
			KEY_LEFT: set_arrow_button_pressed_state(event.keycode, event.pressed)
			KEY_RIGHT: set_arrow_button_pressed_state(event.keycode, event.pressed)

func set_arrow_button_pressed_state(keycode, state: bool) -> void:
	#changes sprite if the corresponding arow key is being pressed
	var keycodeToVariable = {KEY_UP: upArrowButton, KEY_DOWN: downArrowButton, 
	KEY_LEFT:leftArrowButton, KEY_RIGHT:rightArrowButton}
	var arrowButton = keycodeToVariable[keycode]
	
	#arrowButton.toggle_mode = state
	arrowButton.set_pressed(state)
