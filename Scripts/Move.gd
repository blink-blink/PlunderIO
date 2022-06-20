extends BTLeaf

export var boat: NodePath
export var wait_time: float

var _boat
var _direction: Vector2
var _finished_moving = false
var _move_timer: Timer

func _ready():
	_boat = get_node(boat)

func set_timer(agent):
	_move_timer = Timer.new()
	_move_timer.connect("timeout", self, "_on_Timer_timeout")
	_move_timer.one_shot = true
	agent.add_child(_move_timer)

func _tick(_agent: Node, _blackboard: Blackboard) -> bool:
	if _finished_moving:
		_finished_moving = false
		_agent.remove_child(_move_timer)
		_move_timer = null
		_blackboard.set_data("direction",Vector2(randf()*2 - 1,randf()*2 - 1))
		return succeed()
	
	
	if not is_instance_valid(_move_timer):
		set_timer(_agent)
	if _move_timer.is_stopped():
		_move_timer.start(wait_time)
		if not _blackboard.has_data("direction"):
			_blackboard.set_data("direction",Vector2(randf(),randf()))
		_direction = _blackboard.get_data("direction")
	
	return fail()

func _process(delta):
	if not is_instance_valid(_boat):
		return
	if not is_instance_valid(_move_timer):
		return
	if not _finished_moving:
		move_direction()

func move_direction():
	if is_facing_direction(180):
		_boat.move_forward(true)
	else:
		_boat.move_forward(false)
	
	if is_direction_left():
		_boat.steer_right(false)
		_boat.steer_left(true)
	else:
		_boat.steer_right(true)
		_boat.steer_left(false)

func is_direction_left() -> bool:
	var boat_left_xz = Vector2(_boat.global_transform.basis.x.x, _boat.global_transform.basis.x.z).normalized()
	return boat_left_xz.dot(_direction.normalized()) > 0

func is_facing_direction(fov) -> bool:
	var boat_facing_xz = Vector2(_boat.global_transform.basis.z.x, _boat.global_transform.basis.z.z).normalized()
	return boat_facing_xz.dot(_direction.normalized()) > cos(deg2rad(fov/2))

func _on_Timer_timeout():
	_finished_moving = true
