extends Area2D


export var speed = -400


func _process(delta):
	position += Vector2(0, delta * speed)
	if position.y < - 20:
		delete()

func delete():
	queue_free()
	
