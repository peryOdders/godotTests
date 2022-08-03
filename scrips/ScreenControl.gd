extends Node

var in_game = false
signal game_Start(state)


func _ready():
	_recenter()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Start/AnimationPlayer.play("StartText")
	# Make a one-shot timer and wait for it to finish.
	yield(get_tree().create_timer(4), "timeout")
	$HelpLabel.visible = false
	
	
func _process(delta):
	if Input.is_action_just_released("ui_full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
		_recenter()
		
	if Input.is_action_just_released("ui_quit"):
		quit()

	if Input.is_action_just_released("ui_help"):
		_show_help_toggle()

	if Input.is_action_just_released("shot") and not in_game:
		toGame(true)

func _recenter():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)


func _show_help_toggle():
	$HelpLabel.visible = !$HelpLabel.visible

func toGame(state):
	in_game = state
	if state:
		$Start.visible = false
		$AudioStartGame.play()
	else:
		$Start.visible = true
	
	emit_signal("game_Start", state)

	
func quit():
	if in_game:
		toGame(false)
	else:
		get_tree().quit()
