extends ViewportContainer

var screen_factor = 3
var mat = get_material()
onready var gui_settings = $GUISettings

func _ready():
	_recenter()
	active_panel(false)
	gui_settings.get_node("Panel/CheckButtonEnableCRT").pressed = true

func _process(_delta):
	if Input.is_action_just_released("ui_full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
		_recenter()
		
	if Input.is_action_just_released("ui_help"):
		active_panel(not $GUISettings.visible)

	if Input.is_action_just_released("ui_screen_up"):
		scaleScreen(screen_factor + 1)
	if Input.is_action_just_released("ui_screen_down"):
		scaleScreen(screen_factor - 1)



func active_panel(mode:bool):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if not mode else Input.MOUSE_MODE_VISIBLE)
	$GUISettings.visible = mode
	
func _recenter():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size * 0.5 - window_size * 0.5)
	OS.set_window_title("WeaEspasial [0%x1%]".format([window_size.x, window_size.y], "_%"))
	
func scaleScreen(scale):
	screen_factor = scale
	screen_factor = clamp(screen_factor, 1, 6)
	OS.set_window_size(Vector2(384 * screen_factor, 216 * screen_factor))
	_recenter()

func set_mat_parameter(parameter_name:String, to:float, time:float):
	
	var tween = Tween.new()
	add_child(tween)
	
	var param = "shader_param/%".format([parameter_name],"%")
	var from = mat.get_shader_param(param)

	tween.interpolate_property(mat, param, from, to, time,Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()


# GUI events
func _on_CheckButtonEnableCRT_toggled(button_pressed):
	mat.set_shader_param("enabled", button_pressed)

func _on_CheckButtonEnableBlur_toggled(button_pressed):
	$Viewport/Blur.visible = button_pressed



func _on_HSlider_value_changed(value):
	mat.set_shader_param("saturation", value)
