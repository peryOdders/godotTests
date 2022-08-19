extends Node

var in_game = false
signal game_Start(state)

func _ready():
	$Start/AnimationPlayer.play("StartText")
	# Make a one-shot timer and wait for it to finish.
	yield(get_tree().create_timer(4), "timeout")
	$HelpLabel.visible = false
	
	
func _process(_delta):
	
	if Input.is_action_just_released("ui_quit"):
		quit()

	if Input.is_action_just_released("ui_help"):
		_show_help_toggle()

	if Input.is_action_just_released("shot") and not in_game:
		toGame(true)
		

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
