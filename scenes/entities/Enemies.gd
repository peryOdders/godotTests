extends KinematicBody2D


export var life = 5.0

var max_life
var max_bar

func _ready():
	max_bar = $LifeBar/BarFill.rect_size.x
	max_life = life
	
func Hitted():
	blink()

func delete():
	queue_free()

func blink():
	
	var t = $Tween
	var m = $AnimatedSprite.get_material()
	
	t.interpolate_property(m,"shader_param/blink",1, 1, .1,Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	t.start()
	yield(t, "tween_completed")
	m.set_shader_param("blink", 0.0)
	
	
	life = life - 1
	$LifeBar/BarFill.rect_size = Vector2(max_bar * (life / max_life),$LifeBar/BarFill.rect_size.y)
	
	if life <  1:
		delete()
