extends Area2D


export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var shoting = false
var in_game = false

const bullet_path = preload("res://scenes/entities/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite.play()
	position = Vector2(screen_size.x / 2 , screen_size.y / 1.1)
	hide()

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if not in_game:
		return

	if Input.is_action_pressed("shot"):
		shot()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func shot():
	if shoting:
		return
		
	shoting = true
	$AudioShot.play()
	var bullet = bullet_path.instance()
	#get_tree().get_root().add_child(bullet)
	get_parent().add_child(bullet)
	bullet.position = position + Vector2(0,-15)

	yield(get_tree().create_timer(0.5), "timeout")
	shoting = false


func _on_ScreenControl_game_Start(state):
	in_game = state 
	position = Vector2(screen_size.x / 2 , screen_size.y / 1.1)
	if state:
		show()
	else:
		hide()
