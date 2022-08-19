extends KinematicBody2D


export var life = 5.0


export(float) var speed:float = 80

var _player:Node2D
var _velocity:Vector2 = Vector2.ZERO
var _target_position:Vector2 = Vector2.ZERO

var max_life
var max_bar

var shoting = true
var in_game = false
var rng = RandomNumberGenerator.new()

const bullet_path = preload("res://scenes/entities/EnemyBullet.tscn")

func _ready():
	max_bar = $LifeBar/BarFill.rect_size.x
	max_life = life
	add_player(Global.player_ref)
	_target_position = get_target_position(0.0, -60.0)
		
	yield(get_tree().create_timer(1.0), "timeout")
	shoting = false

func Hitted():
	blink()

func delete():
	queue_free()

func blink():
	
	var t = $Tween
	var m = $AnimatedSprite.get_material()
	
	t.interpolate_property(m,"shader_param/blink",1 ,0, .4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	t.start()
	yield(t, "tween_completed")
	m.set_shader_param("blink", 0.0)
	
	life = life - 1
	$LifeBar/BarFill.rect_size = Vector2(max_bar * (life / max_life),$LifeBar/BarFill.rect_size.y)
	
	if life <  1:
		delete()

func _physics_process(delta):
	
	var collisionL = $RayCast2DL.is_colliding()
	var collisionR = $RayCast2DR.is_colliding()
	
	_velocity = move_and_slide(_velocity, Vector2.UP)

	var collision_dir = 0.5
	
	if position.x < 10.0 or position.x > 374.0:
		collision_dir = -0.5
		_target_position = get_target_position(0.0 , -60.0)
		
	if collisionL: 
		_target_position = get_target_position($RayCast2DL.get_collider().position.x - _player.position.x - 10.0 , -60)

	if collisionR: 
		_target_position = get_target_position($RayCast2DR.get_collider().position.x - _player.position.x + 10.0 , -60)

			
	var destiny = _player.global_transform.origin + _target_position
	var distance = position.distance_to(destiny)
	
	var direction_to_player = global_transform.origin.direction_to(destiny)
	_velocity.x = direction_to_player.x  * distance
	_velocity.y = direction_to_player.y * distance * collision_dir
	
	if abs(position.x - _player.position.x) < 5: shot()
	
func add_player(p):
	_player = p
	print ("Player " + _player.name)
	
func shot():
	if shoting:
		return

	shoting = true
	var t = rng.randf_range(1.0, 3.0)
	var bullet = bullet_path.instance()
	get_parent().add_child(bullet)
	bullet.position = position - Vector2(0,-20)
	bullet.velocity = Vector2(0.0, 1.0)
	bullet.speed = 60

	yield(get_tree().create_timer(t), "timeout")
	shoting = false

func get_target_position(offset_x:float, offset_y:float) -> Vector2:
	return Vector2(offset_x , offset_y)
	
