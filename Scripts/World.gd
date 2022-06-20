extends Node

var player_scene = preload("res://Scenes/Player.tscn")

onready var player_spawn = $SpawnLocations/PlayerSpawn
onready var mob_spawn_location = $SpawnLocations/Mob/MobSpawnLocation
onready var mobs = $Mobs

var INIT_MOB_NUM = 15

func _physics_process(delta):
	pass

func _ready():
	#network signals
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	randomize()
	for player in Global.Players:
		var player_instance = create_player(player)
		
		#if multiplayer
		if not get_tree().has_network_peer():
			continue
		if player == get_tree().get_network_unique_id():
			rpc("player_loaded",player, player_instance.global_transform)
	
#	#create mobs for single player only for now
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	for i in INIT_MOB_NUM:
		init_mob()

#rpc
remote func player_loaded(id, transform):
	print("player ", id, " has loaded")
	create_player(id).global_transform = transform
	
	if not get_tree().get_network_unique_id() == 1:
		return
	for mob in mobs.get_children():
		if not is_instance_valid(mob.Boat):
			continue
		print("create_mob ("+mob.name+") requested")
		rpc_id(id, "create_mob", mob.name, mob.TYPE, mob.global_transform.origin,
						mob.Boat.global_transform,
						mob.Boat.linear_velocity,
						mob.Boat.angular_velocity,
						mob.Boat.HIT_POINTS)

remote func create_mob(m_name, type, origin, b_transform, linear_vel, angular_vel, hp):
	var mob = GameData.mob_scene[type].instance()
	mob.name = m_name
	mobs.add_child(mob)
	mob.global_transform.origin = origin
	mob.Boat.global_transform = b_transform
	mob.Boat.linear_velocity = linear_vel
	mob.Boat.angular_velocity = linear_vel
	mob.Boat.HIT_POINTS = hp
	mob._on_Boat_Update()
	print("mob ("+mob.name+") type: " + type + " created")

func _player_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()

func create_player(id) -> Node:
	print("player created for Player " + str(id))
	var player = player_scene.instance()
	player.initialize(get_random_player_spawn())
	player.set_network_master(id)
	player.name = str(id)
	
	add_child(player)
	return player

func get_random_player_spawn() -> Vector3:
	var player_spawn_locations = player_spawn.get_children()
	var random_index = randi() % player_spawn_locations.size()
	return player_spawn_locations[random_index].global_transform.origin

func init_mob():
	var mob
	if randi() % 7 == 0:
		mob = GameData.mob_scene["ManOWar"].instance()
	else:
		mob = GameData.mob_scene["Dummy"].instance()
	mob_spawn_location.unit_offset = randf()
	mob.initialize(mob_spawn_location.translation)
	mobs.add_child(mob)
	mob.name = "mob"+str(mobs.get_child_count())
	print("Mob ("+mob.name+"): " + mob.TYPE + "intialized")

func quit_game():
	Network.disconnect_to_server()
	
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
	
	queue_free()
