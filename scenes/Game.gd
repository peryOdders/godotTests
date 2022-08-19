extends Node2D

var current_time = 0.0
var spawn_rate = 6.0

func _ready():
	for n in 6:
		spawn(0)
	pass

func _process(delta):
	current_time += delta
	#if current_time > spawn_rate:
		#spawn(0)
		
func spawn(id):
	$EnemiesSpawner.spawn(id)
	current_time = 0
	spawn_rate -= 0.5
	if spawn_rate < 1.0: spawn_rate = 1.0
