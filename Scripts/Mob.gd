extends Spatial

class_name Mob

#Network tick
const NETWORK_TICK_RATE = 0.03
var network_tick = 0

onready var healthbar = $Boat/HealthBar3D/Viewport/HealthBar
onready var detection_marker = $Boat/DetectionMarker
onready var HealthBar3D = $Boat/HealthBar3D
onready var Boat = $Boat
export(NodePath) onready var boat_tween = get_node(boat_tween) as Tween

var bar = preload("res://barHorizontal_green_mid 200.png")

#Boat data
var TYPE

func initialize(init_location):
	global_translate(init_location)

func _ready():
	healthbar.max_value = Boat.HIT_POINTS
	healthbar.value = Boat.HIT_POINTS
	healthbar.texture_progress = bar
	HealthBar3D.show()
	HealthBar3D.texture = $Boat/HealthBar3D/Viewport.get_texture()

func _process(delta):
	#send boat values every tick
	Network_tick(delta)

#multiplayer
func Network_tick(delta):
	if not get_tree().has_network_peer():
		return
	
	if not is_network_master():
		return
	
	if not is_instance_valid(Boat):
		return
	
	if network_tick <= 0:
		network_tick = NETWORK_TICK_RATE
		rpc_unreliable("update_boat", Boat.global_transform, Boat.angular_velocity, Boat.linear_velocity)
	else:
		network_tick -= delta

#rpc
puppet func update_boat(p_transform, p_angular_vel, p_linear_vel):
	if is_instance_valid(Boat):
#		Boat.global_transform = puppet_transform
		Boat.angular_velocity = p_angular_vel
		Boat.linear_velocity = p_linear_vel
		boat_tween.interpolate_property(Boat, "global_transform", Boat.global_transform, p_transform, 0.1)
		boat_tween.start()

#this is an experiment (everyone gets to update the puppet)
puppet func update_hp(p_hp):
	if not is_instance_valid(Boat):
		return
	print("puppet func update")
	Boat.HIT_POINTS = p_hp
	_on_Boat_Update()

func _on_Boat_Update():
	if not is_instance_valid(Boat):
		return
	
	print("Mob (" + name +") updated")
	if Boat.is_alive():
		print(Boat.HIT_POINTS)
		healthbar.value = Boat.HIT_POINTS
	else:
		$BehaviorTree.is_active = false
		healthbar.hide()
		detection_marker.hide()
	
	if is_network_master():
		rpc("update_hp", Boat.HIT_POINTS)


func _on_Boat_on_queue_free():
	queue_free()
