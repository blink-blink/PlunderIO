extends Spatial

export (PackedScene) var cannon_missile_scene
onready var cannon_muzzle = $CannonHead/Muzzle
var cannon_particle = preload("res://Scenes/CannonParticle.tscn")

var is_aiming = false
#onready var line_trajectory = $Muzzle/LineTrajectory
var line_max_points = 5
var player_controlled = false

func _process(delta):
	if is_aiming:
		draw_trajectory(delta)
	pass

func draw_trajectory(delta):
#	line_trajectory.curve.clear_points()
#	var init_offset_transform = get_parent().get_parent().get_parent().global_transform.origin
#	var pos = $Muzzle.global_transform.origin - init_offset_transform
#	var vel = $Muzzle.global_transform.origin * 50
#	var points = []
#	for i in line_max_points:
#		points.append(pos)
#		var point_skip = 100/line_max_points
#		vel.y += 9.8 * delta*point_skip
#		pos += vel * delta*point_skip
#		line_trajectory.curve.add_point(pos)
	pass

func set_player_controlled(player_controlled):
	self.player_controlled = player_controlled

func _unhandled_input(event):
	if player_controlled:
		if event.is_action_pressed("cannon_fire") and not is_aiming:
			aim()
		if event.is_action_released("cannon_fire") and is_aiming:
			fire()

func aim():
	is_aiming = true
	pass

func fire():
	is_aiming = false
	$FireDelay.start(randf()*0.3)

func _on_FireDelay_timeout():
	var cannon_head = $CannonHead
	$CannonHead/Muzzle/CannonParticle.restart()
#	cannon_muzzle.add_child(cannon_particle.instance())
	var cannon_missile = cannon_missile_scene.instance()
	cannon_missile.initialize($CannonHead/Muzzle.global_transform.origin, cannon_head.global_transform.basis.y.normalized())
	get_node("/root/World").add_child(cannon_missile)
