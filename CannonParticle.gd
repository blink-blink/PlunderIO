extends Particles

var time = 0

func _process(delta):
	time += delta
	if time > lifetime:
		queue_free()
