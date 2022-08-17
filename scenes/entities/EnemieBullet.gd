extends KinematicBody2D


export var dir = Vector2(0,0)

func _ready():
	position = Vector2(100,50)

func _process(delta):
	position  += Vector2(dir.x * delta, dir.y * delta )
