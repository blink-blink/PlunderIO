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
	
	if last_target:
		if is_instance_valid(last_target):
			closest_distance = distance_to_target(boat, last_target)
		else:
			if get_tree().has_network_peer() and get_tree().get_network_unique_id() == 1:
				agent.rpc("sync_network_master", 1)
			last_target = null
			blackboard.set_data("target", null)
	
	if candidate_targets.size() <= 0:
		detection_marker.hide()
		return fail()
	
	for candidate_target in candidate_targets:
		if blackboard.has_data("target") and distance_to_target(boat, candidate_target) > closest_distance:
			continue
			
		blackboard.set_data("target", candidate_target)
		closest_distance = distance_to_target(boat, candidate_target) 
	
	if not blackboard.get_data("target"):
		detection_marker.hide()
		return fail()
	
	#change master on new target if multiplayer
	var new_master_id = int(blackboard.get_data("target").get_parent().name)
	if last_target != blackboard.get_data("target") and get_tree().has_network_peer():
		if new_master_id == get_tree().get_network_unique_id():
			agent.rpc("sync_network_master", new_master_id)
	
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
