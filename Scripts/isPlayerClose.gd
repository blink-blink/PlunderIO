extends BTLeaf


onready var detection_marker = owner.get_node("Boat/DetectionMarker")

var playersClose = 0


func _tick(_agent: Node, _blackboard: Blackboard) -> bool:
	if playersClose > 0:
		return succeed()
	return fail()

func _on_AreaDetection_body_entered(body):
	if not body.is_in_group("PlayerBoat"):
		return
		
	if playersClose <= 0:
		detection_marker.show()
	playersClose += 1


func _on_AreaDetection_body_exited(body):
	if not body.is_in_group("PlayerBoat"):
		return
		
	playersClose -= 1
	if playersClose <= 0:
		detection_marker.hide()
