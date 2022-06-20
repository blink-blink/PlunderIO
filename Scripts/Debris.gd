extends RigidBody

class_name Debris
	
onready var Water = get_node("/root/World/Water")
onready var Floaters = $Floaters

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

func initialize(init_location, force_vector):
	add_torque(Vector3(randf(),randf(),randf())*10)
	global_translate(init_location+Vector3(randf(),0,randf()))
	apply_central_impulse(force_vector)

func _physics_process(delta):
	apply_buoyant_force()

func apply_buoyant_force():
	
	var wh = Water.calculateWaveHeight(global_transform.origin.x, global_transform.origin.z)
	
	var fPoint = Floaters.get_children()
	for index in range (0, fPoint.size()):
		var fPos = fPoint[index].global_transform.origin
		wh = Water.calculateWaveHeight(fPos.x, fPos.z)
		if fPos.y < wh:
			#max value is the volume of the boat
			var bV = (mass*1.5)/fPoint.size()
			add_force(Vector3.UP*GRAVITY*(clamp(wh - fPos.y,0,bV)), fPos - global_transform.origin)
