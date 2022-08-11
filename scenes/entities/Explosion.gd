extends Node


func _ready():
	$AnimatedSprite.play("boom")
	$Particles2D.emitting = true


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.hide()
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
	
