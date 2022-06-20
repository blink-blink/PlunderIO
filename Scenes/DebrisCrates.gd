extends Debris

var gold_amount = 100
var contains_cannon = false

func _on_debris_pick_up(body):
	if body.is_alive():
		queue_free()
	pass # Replace with function body.
