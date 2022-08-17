extends KinematicBody2D


export var speed = -400
var velocity = Vector2()

const explosion_path = preload("res://scenes/entities/Explosion.tscn")

func explode():
	var explosion = explosion_path.instance()
	get_parent().add_child(explosion)
	explosion.position = position
	delete()

func _physics_process(delta):
	velocity = Vector2(0.0,1.0)
	velocity = velocity.normalized() * speed

	var collision = move_and_collide(velocity * delta)
	if collision:
		collision.collider.call_deferred("Hitted")
		explode()

func delete():
	queue_free()

func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	delete()
