extends Spatial

const MAX_ZOOM = 100
const MIN_ZOOM = 50

onready var camera = $h/v/Camera

var camrot_h = 0
var camrot_v = 0
var cam_v_min = 75
var cam_v_max = -55
var sensitivity = 0.5
var acceleration = 10
var current_zoom
var zoom_factor = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#camera.add_exception(get_parent())
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	camera.current = true
	current_zoom = camera.fov


func _unhandled_input(event):
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * sensitivity
		camrot_v += event.relative.y * sensitivity
	elif event.is_action_pressed("scroll_down") and camera.fov < MAX_ZOOM:
		current_zoom += zoom_factor
	elif event.is_action_pressed("scroll_up") and camera.fov > MIN_ZOOM:
		current_zoom -= zoom_factor

func _physics_process(delta):
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	clamp(camrot_v, cam_v_min, cam_v_max)
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot_h, delta * acceleration)
	$h/v.rotation_degrees.x = lerp($h.rotation_degrees.x, camrot_v, delta * acceleration)
	camera.fov = lerp(camera.fov, current_zoom, delta * acceleration)
