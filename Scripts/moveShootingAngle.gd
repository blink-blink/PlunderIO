extends BTLeaf

var SHOOTING_DISTANCE = 40
var SHOOTING_MAX_DISTANCE = 60
var SHOOTING_FOV = 15
var last_target

func _tick(_agent: Node, _blackboard: Blackboard) -> bool:
	return move_to_target(_agent, _blackboard)

func move_to_target(agent: Node, blackboard: Blackboard) -> bool:
	var boat: Boat = agent.get_node("Boat")
	
	if not is_instance_valid(boat) or not blackboard.has_data("target"):
		return fail()
		
	var target = blackboard.get_data("target")
		
	if is_target_left(boat, target,15) and distance_to_target(boat, target) <= SHOOTING_MAX_DISTANCE:
		boat.shoot()
		
	if distance_to_target(boat, target) > SHOOTING_DISTANCE:
		if is_facing_target(boat, target,45):
			boat.move_forward(true)
		if is_target_left(boat, target,180):
			boat.steer_left(true)
			boat.steer_right(false)
		else:
			boat.steer_left(false)
			boat.steer_right(true)
	else:
		boat.move_forward(false)
		boat.move_backward(false)
		if is_target_left_of_left(boat, target,180):
			if is_target_left(boat, target,45):
				boat.move_backward(true)
				boat.steer_left(false)
				boat.steer_right(true)
			else:
				boat.move_backward(false)
				boat.steer_left(true)
				boat.steer_right(false)
		else:
			if is_target_left(boat, target,45):
				boat.move_forward(true)
			else:
				boat.move_forward(false)
			boat.steer_left(false)
			boat.steer_right(true)
	
	return succeed()

func is_facing_target(boat, target,fov) -> bool:
	return (boat.global_transform.basis.z).dot((target.global_transform.origin-boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func is_target_left(boat, target,fov) -> bool:
	return (boat.global_transform.basis.x).dot((target.global_transform.origin-boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func is_target_left_of_left(boat, target,fov) -> bool:
	return (-boat.global_transform.basis.z).dot((target.global_transform.origin-boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func is_target_right(boat, target,fov) -> bool:
	return (-boat.global_transform.basis.x).dot((target.global_transform.origin-boat.global_transform.origin).normalized()) > cos(deg2rad(fov/2))

func distance_to_target(boat, target):
	return boat.global_transform.origin.distance_to(target.global_transform.origin)
