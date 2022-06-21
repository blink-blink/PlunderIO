extends RigidBody

class_name Boat

onready var Water = get_node("/root/World/Water")
onready var Floaters = $Floaters
onready var Cannons = $Cannons
onready var DebrisBonuses = preload("res://Scenes/DebrisBonuses.tscn")
onready var DebrisCrates = preload("res://Scenes/DebrisCrates.tscn")

#Boat param
export var BOAT_MAX_HEIGHT = 2.7
export var HIT_POINTS = 100
export var ATTACK_SPEED = 1.0
export var MOVEMENT_SPEED = 200.0
export var TURN_SPEED = 50.0

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

#movement commands
var moving_forward = false
var moving_backward = false
var steering_left = false
var steering_right = false
var shooting = false

#network
var is_puppet = false

signal damaged
signal on_queue_free

func _ready():
	MOVEMENT_SPEED *= 9.8
	TURN_SPEED *= 9.8
	pass

func set_player_controlled(player_controlled):
	if player_controlled:
		for cannon in Cannons.get_children():
			cannon.set_player_controlled(true)

func set_puppet(b):
	# if puppet, it's master controls the update
	is_puppet = b

func _physics_process(delta):
	
	var wh = Water.calculateWaveHeight(global_transform.origin.x, global_transform.origin.z)
	
	if is_alive():
		#movement
		control_movement(wh)
		
		#buoyant force
		apply_buoyant_force(wh)
	else:
		#buoyant force 
		if global_transform.origin.y < -10:
			emit_signal("on_queue_free")
			queue_free()
			return
		if global_transform.origin.y < wh:
				add_central_force(Vector3.UP*(mass*2)*(clamp(pow((wh - global_transform.origin.y)*0.9,4),0,1)))
				var bV = mass*0.10
				var fPos = $Floaters/FloaterPoint10.global_transform.origin
				add_force(Vector3.UP*GRAVITY*(clamp(wh - fPos.y,0,bV)), fPos - global_transform.origin)

func apply_buoyant_force(wh):
	
	var floaters_influence = 0.1
	var boat_influence = 1 - floaters_influence
	
	var dFluid_volume
	var density_diff = 7
	
	if global_transform.origin.y < wh:
			dFluid_volume = pow(clamp(wh - global_transform.origin.y,0,BOAT_MAX_HEIGHT)/BOAT_MAX_HEIGHT*10,3)/1000
			add_central_force(Vector3.UP*GRAVITY*(mass*density_diff*boat_influence)*dFluid_volume)
	
	var fPoint = Floaters.get_children()
	for index in range (0, fPoint.size()):
		var fPos = fPoint[index].global_transform.origin
		wh = Water.calculateWaveHeight(fPos.x, fPos.z)
		if fPos.y < wh:
			#max value is the volume of the boat
			var bV = (mass*density_diff*floaters_influence)/fPoint.size()
			add_force(Vector3.UP*GRAVITY*bV*(clamp(wh - fPos.y,0,1)), fPos - global_transform.origin)

func control_movement(wh):
	var movement = global_transform.basis.z
	
	if moving_forward: 
		if global_transform.origin.y <= wh:
			add_central_force(movement*MOVEMENT_SPEED)
		else:
			add_central_force(Vector3(movement.x,0,movement.z)*MOVEMENT_SPEED)
	if moving_backward:
		if global_transform.origin.y <= wh:
			add_central_force(-movement*MOVEMENT_SPEED)
		else:
			add_central_force(-Vector3(movement.x,0,movement.z)*MOVEMENT_SPEED)
	if steering_left:
		if moving_backward:
			add_torque(global_transform.basis.y*-TURN_SPEED)
		else:
			add_torque(global_transform.basis.y*TURN_SPEED)
	if steering_right:
		if moving_backward:
			add_torque(global_transform.basis.y*TURN_SPEED)
		else:
			add_torque(global_transform.basis.y*-TURN_SPEED)

#movement commands
func move_forward(b):
	moving_forward = b

func move_backward(b):
	moving_backward = b

func steer_left(b):
	steering_left = b

func steer_right(b):
	steering_right = b

func shoot():
	if not is_alive():
		return
	for cannon in Cannons.get_children():
		cannon.fire()

#events
var last_contact_normal = []
var last_collider_velocity = []

func _integrate_forces(state):
	last_contact_normal.clear()
	for i in state.get_contact_count():
		last_contact_normal.append(state.get_contact_local_normal(i))
		last_collider_velocity.append(state.get_contact_collider_velocity_at_position(i))

func boat_hit(body):
	if is_puppet:
		return
	
	for i in range(get_colliding_bodies().size()):
		body = get_colliding_bodies()[i]
		if not (body.is_in_group("hazard") and is_alive()):
			continue
		
		#need to be updated such that the full velocity before impact gets passed
		var normal_velocity_alignment = body.linear_velocity.dot(last_contact_normal[i])/body.FULL_DAMAGE_VELOCITY
#		var normal_velocity_alignment_b = last_collider_velocity[i].dot(last_contact_normal[i])/body.FULL_DAMAGE_VELOCITY
		if normal_velocity_alignment > 0:
			HIT_POINTS -= body.damage
			emit_signal("damaged")
		
		if not is_alive():
			on_death()
			break

func on_death():
	var debris_bonuses
	for index in range(0,randi()%5+1):
		if randi()%3 == 1:
			debris_bonuses = DebrisCrates.instance()
		else:
			debris_bonuses = DebrisBonuses.instance()
		debris_bonuses.initialize(global_transform.origin + Vector3.UP*2, Vector3(randf(),1,randf()).normalized()*randf())
		get_node("/root/World").add_child(debris_bonuses)
	pass

#getters
func is_alive() -> bool:
	return HIT_POINTS > 0
