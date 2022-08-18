extends KinematicBody2D


export var velocity = Vector2.ZERO
export var speed = 0.0


func _ready():
	pass
	
func _physics_process(delta):
	
	velocity = velocity.normalized() * speed

	var collision = move_and_collide(velocity * delta)
	if collision:
		collision.collider.call_deferred("Hitted")
		queue_free()
	if position.y > 220:
		queue_free()
