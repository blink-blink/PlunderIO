extends Spatial

#signals
#signal player_loaded(transform)

#Network tick
const NETWORK_TICK_RATE = 0.03
var network_tick = 0

#Nodes
onready var Boat = $Boat
onready var HealthBar = $HUD/HealthBar
onready var HealthBar3d: Sprite3D = $Boat/HealthBar3D
onready var FHB_Viewport: Viewport = $Boat/HealthBar3D/Viewport
onready var FHealthBar: TextureProgress = $Boat/HealthBar3D/Viewport/HealthBar
onready var CamPivot: Spatial = $CamPivot
export(NodePath) onready var boat_tween = get_node(boat_tween) as Tween

#puppet
var puppet_transform = Transform()
var puppet_linear_vel = Vector3()
var puppet_angular_vel = Vector3()

var control_boat = true
var gold = 100
var type = "Schooner"

func initialize(init_location):
	global_translate(init_location)

func _ready():
	if get_tree().has_network_peer():
		if not is_network_master():
			$HUD.hide()
			HealthBar3d.show()
			HealthBar3d.texture = FHB_Viewport.get_texture()
			update_healthbar_data()
			Boat.set_puppet(true)
			return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$HUD/GoldLabel.text = "Gold: %s" % gold
	HealthBar.max_value = Boat.HIT_POINTS
#	Boat.set_player_controlled(true)

func _process(delta):
	#send boat values every tick
	Network_tick(delta)

func _physics_process(delta):
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	#vars
	var acceleration = 20
	
	#camera
	if not control_boat:
		return
		
	CamPivot.global_transform.origin.x = lerp(CamPivot.global_transform.origin.x, Boat.global_transform.origin.x, delta*acceleration)
	CamPivot.global_transform.origin.y = lerp(CamPivot.global_transform.origin.y, Boat.global_transform.origin.y, delta*acceleration)
	CamPivot.global_transform.origin.z = lerp(CamPivot.global_transform.origin.z, Boat.global_transform.origin.z, delta*acceleration)

func _unhandled_input(event):
	if get_tree().has_network_peer():
		if not is_network_master():
			return

	if control_boat:
		if event.is_action_pressed("move_forward"): 
			Boat.move_forward(true)
		elif event.is_action_released("move_forward"):
			Boat.move_forward(false)
			
		if event.is_action_pressed("move_back"):
			Boat.move_backward(true)
		elif event.is_action_released("move_back"):
			Boat.move_backward(false)
			
		if event.is_action_pressed("move_left"):
			Boat.steer_left(true)
		elif event.is_action_released("move_left"):
			Boat.steer_left(false)
			
		if event.is_action_pressed("move_right"):
			Boat.steer_right(true)
		elif event.is_action_released("move_right"):
			Boat.steer_right(false)
		
		if event.is_action_pressed("cannon_fire"):
			Boat.shoot()
			if get_tree().has_network_peer():
				rpc("update_p_shoot", true)

remotesync func change_boat(boat) -> bool:
	if not boat in GameData.ship_data:
		print("change_boat: "+ boat + " not found")
		return false
	
	var transform = Boat.global_transform
	var name = Boat.name
	
	#remove old boat
	Boat.remove_child(HealthBar3d)
	remove_child(Boat)
	
	#add new boat
	Boat = GameData.ship_data[boat]["scene"].instance()
	Boat.add_child(HealthBar3d)
	add_child(Boat)
	
	#set boat values
	Boat.name = name
	Boat.global_transform = transform
	update_healthbar_data()
	Boat.add_to_group("PlayerBoat")
	
	#connect signals
	Boat.connect("damaged", self, "_on_Boat_Update")
	
	#scale cam pivot
	var scale_val = GameData.ship_data[boat]["camscale"]
	CamPivot.scale = Vector3(scale_val,scale_val,scale_val)
	
	#set new type
	type = boat
	
	return true

func update_healthbar_data():
	FHealthBar.max_value = Boat.HIT_POINTS
	FHealthBar.value = Boat.HIT_POINTS
	HealthBar.max_value = Boat.HIT_POINTS
	HealthBar.value = Boat.HIT_POINTS

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
		rpc_update_boat()
	else:
		network_tick -= delta

func rpc_update_boat():
	rpc_unreliable("update_boat", Boat.global_transform, Boat.angular_velocity, Boat.linear_velocity)

#rpc	
puppet func update_boat(p_transform, p_angular_vel, p_linear_vel):
	puppet_transform = p_transform
	puppet_angular_vel = p_angular_vel
	puppet_linear_vel = p_linear_vel
	if is_instance_valid(Boat):
		Boat.angular_velocity = puppet_angular_vel
		Boat.linear_velocity = puppet_linear_vel
		boat_tween.interpolate_property(Boat, "global_transform", Boat.global_transform, p_transform, 0.1)
		boat_tween.start()

puppet func update_p_shoot(p_shoot):
	Boat.shoot()

puppet func update_hp(p_hp):
	Boat.HIT_POINTS = p_hp
	FHealthBar.value = Boat.HIT_POINTS
	
	#call the func for death for puppet
	if not Boat.is_alive():
		Boat.on_death()

func _on_Boat_Update():
	if get_tree().has_network_peer():
		if not is_network_master():
			return
		
	print("boat updated")
	HealthBar.value = Boat.HIT_POINTS
	if not Boat.is_alive():
		control_boat = false
	
	if get_tree().has_network_peer():
		rpc("update_hp", Boat.HIT_POINTS)
