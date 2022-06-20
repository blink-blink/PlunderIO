extends BTLeaf

export var boat: NodePath

var _boat
var near_islands: int = 0

func _ready():
	_boat = get_node(boat)

func _tick(_agent: Node, _blackboard: Blackboard) -> bool:
	return succeed()
#	if near_islands <= 0:
#		return succeed()
#	return fail()


func _on_AreaDetection_body_entered(body):
	if body.is_in_group("Island"):
		near_islands += 1
	


func _on_AreaDetection_body_exited(body):
	if body.is_in_group("Island"):
		near_islands -= 1
