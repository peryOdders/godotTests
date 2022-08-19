extends Node2D

export(Array, PackedScene) var enemies

var rng = RandomNumberGenerator.new()

func spawn(id):
	var enemy = enemies[id].instance()
	add_child(enemy)

	rng.randomize()
	var x = rng.randf_range(0, 384.0)
	var y = rng.randf_range(-180, -40.0)
	enemy.position = position + Vector2(x,y)
