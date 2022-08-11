extends Area2D


export var speed = -400
const explosion_path = preload("res://scenes/entities/Explosion.tscn")

func explode():
	var explosion = explosion_path.instance()
	get_parent().add_child(explosion)
	explosion.position = position

func _process(delta):
	position += Vector2(0, delta * speed)
	if position.y < + 60:
		delete()

func delete():
	explode()
	queue_free()
	
