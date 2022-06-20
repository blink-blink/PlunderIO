extends BTLeaf

export var boat: NodePath
export(NodePath) onready var mob = get_node(mob) as Node

var SHOOTING_DISTANCE = 40
var SHOOTING_MAX_DISTANCE = 60
var SHOOTING_FOV = 15
var _boat: Boat
var _targets = []
var last_target

func _ready():
	_boat = get_node(boat)

func _tick(_agent: Node, _blackboard: Blackboard) -> bool:
	return move_to_target()

func move_to_target() -> bool:
	if not is_instance_valid(_boat):
		return fail()
		
	var target = pick_closest_target()
	
	if _targets.size() <= 0:
		_boat.steer_left(false)
		_boat.steer_right(false)
		_boat.move_forward(false)
		_boat.move_backward(false)
		return fail()
		
	if is_target_left(target,15) and distance_to_target(target) <= SHOOTING_MAX_DISTANCE:
		_boat.shoot()
		
	if distance_to_target(target) > SHOOTING_DISTANCE:
		if is_facing_target(target,45):
			_boat.move_forward(true)
		if is_target_left(target,180):
			_boat.steer_left(true)
			_boat.steer_right(false)
		else:
			_boat.steer_left(false)
			_boat.steer_right(true)
	else:
		_boat.move_forward(false)
		_boat.move_backward(false)
		if is_target_left_of_left(target,180):
			if is_target_left(target,45):
				_boat.move_backward(true)
				_boat.steer_left(false)
				_boat.steer_right(true)
			else:
				_boat.move_backward(false)
				_boat.steer_left(true)
				_boat.steer_right(false)
		else:
			if is_target_left(target,45):
				_boat.move_forward(true)
			else:
				_boat.move_forward(false)
			_boat.steer_left(false)
			_boat.steer_right(true)
	
	return succeed()

func is_facing_target(target,fov) -> bool:
	return (_boat.global_transform.basis.z).dot((target.global_transform.origin-_boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func is_target_left(target,fov) -> bool:
	return (_boat.global_transform.basis.x).dot((target.global_transform.origin-_boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func is_target_left_of_left(target,fov) -> bool:
	return (-_boat.global_transform.basis.z).dot((target.global_transform.origin-_boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func is_target_right(target,fov) -> bool:
	return (-_boat.global_transform.basis.x).dot((target.global_transform.origin-_boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func distance_to_target(target):
	return _boat.global_transform.origin.distance_to(target.global_transform.origin)

func pick_closest_target():
	var closest_target
	var closest_distance = -1
	var distance
	for target in _targets:
		distance = distance_to_target(target)
		if closest_distance == -1:
			closest_distance = distance
			closest_target = target
		elif distance < closest_distance:
			closest_distance = distance
			closest_target = target
	
	#change master on new target if multiplayer
	if last_target != closest_target and closest_target != null and get_tree().has_network_peer():
		print("master changed")
		last_target = closest_target
		mob.set_network_master(int(last_target.get_parent().name))
		if mob.is_network_master():
			_boat.set_puppet(false)
		else:
			_boat.set_puppet(true)
		
	return closest_target

func _on_AreaDetection_body_entered(body):
	if body.is_in_group("PlayerBoat"):
		print("target entered")
		_targets.append(body)


func _on_AreaDetection_body_exited(body):
	if body.is_in_group("PlayerBoat"):
		print("target exited")
		_targets.erase(body)
