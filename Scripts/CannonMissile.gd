extends RigidBody

const FULL_DAMAGE_VELOCITY = 50
var damage = 10

func _ready():
	pass

func initialize(init_location, force_vector):
	apply_central_impulse(force_vector*50)
	global_transform.origin = init_location
	add_to_group("hazard")

func _physics_process(delta):
	if global_transform.origin.y <= -5.24:
		queue_free()

func missile_hit(body):
	pass

func _on_CannonMissile_body_exited(body):
	#add_to_group("hazard")
	pass # Replace with function body.
