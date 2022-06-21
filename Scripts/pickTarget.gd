extends BTLeaf


onready var detection_marker: Sprite3D = owner.get_node("Boat/DetectionMarker")
onready var area_detection: Area = owner.get_node("Boat/AreaDetection")

var candidate_targets: Array

func _tick(_agent: Node, _blackboard: Blackboard) -> bool:
	return pick_target(_agent, _blackboard)

func pick_target(agent: Node, blackboard: Blackboard):
	var boat: Boat = agent.get_node("Boat")
	var last_target: Boat = blackboard.get_data("target")
	var closest_distance = -1
	
	if candidate_targets.size() <= 0:
		detection_marker.hide()
		return fail()
	
	if blackboard.has_data("target"):
		closest_distance = distance_to_target(boat, blackboard.get_data("target"))
	
	for candidate_target in candidate_targets:
		if blackboard.has_data("target") and distance_to_target(boat, candidate_target) > closest_distance:
			continue
			
		blackboard.set_data("target", candidate_target)
		closest_distance = distance_to_target(boat, candidate_target) 
	
	if not blackboard.get_data("target"):
		detection_marker.hide()
		return fail()
	
	#change master on new target if multiplayer
	if last_target != blackboard.get_data("target") and get_tree().has_network_peer():
		print("master changed")
		agent.set_network_master(int(last_target.get_parent().name))
		if agent.is_network_master():
			boat.set_puppet(false)
		else:
			boat.set_puppet(true)
	
	detection_marker.show()
	return succeed()

func distance_to_target(boat: Boat, target: Boat):
	return boat.global_transform.origin.distance_to(target.global_transform.origin)


func _on_AreaDetection_body_entered(body):
	if body.is_in_group("PlayerBoat"):
		candidate_targets.append(body)


func _on_AreaDetection_body_exited(body):
	if body.is_in_group("PlayerBoat"):
		candidate_targets.erase(body)
