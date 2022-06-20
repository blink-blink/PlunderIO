extends Spatial

#network
const NETWORK_TICK_RATE = 0.03
var server_time = 0.0
var network_tick = 0

class vec4:
	var direction
	var z
	var w
	
	func _init(direction, z, w):
		self.direction = direction
		self.z = z
		self.w = w

#elapsed time for lerp
var l_time = 0.0
var time = 0.0
var wave = []

const pi = 3.14159265358979323846264338327950288419716939937510582097494459230781640628

func _ready():
	var w1x = $WaterMesh.get_active_material(0).get_shader_param("waveA").x
	var w1y = $WaterMesh.get_active_material(0).get_shader_param("waveA").y
	var w1z = $WaterMesh.get_active_material(0).get_shader_param("waveA").z
	var w1w = $WaterMesh.get_active_material(0).get_shader_param("waveA").d
	addWave(w1x,w1y,w1z,w1w)
	var w2x = $WaterMesh.get_active_material(0).get_shader_param("waveB").x
	var w2y = $WaterMesh.get_active_material(0).get_shader_param("waveB").y
	var w2z = $WaterMesh.get_active_material(0).get_shader_param("waveB").z
	var w2w = $WaterMesh.get_active_material(0).get_shader_param("waveB").d
	addWave(w2x,w2y,w2z,w2w)
	var w3x = $WaterMesh.get_active_material(0).get_shader_param("waveC").x
	var w3y = $WaterMesh.get_active_material(0).get_shader_param("waveC").y
	var w3z = $WaterMesh.get_active_material(0).get_shader_param("waveC").z
	var w3w = $WaterMesh.get_active_material(0).get_shader_param("waveC").d
	addWave(w3x,w3y,w3z,w3w)
	var w4x = $WaterMesh.get_active_material(0).get_shader_param("waveD").x
	var w4y = $WaterMesh.get_active_material(0).get_shader_param("waveD").y
	var w4z = $WaterMesh.get_active_material(0).get_shader_param("waveD").z
	var w4w = $WaterMesh.get_active_material(0).get_shader_param("waveD").d
	addWave(w4x,w4y,w4z,w4w)
	
	#set to 1 so that client's wave are sync with server
	set_network_master(Global.Players[0])

func _process(delta):
	$WaterMesh.get_active_material(0).set_shader_param("time", time)
	
	time += delta
	
	if get_tree().has_network_peer():
		if not is_network_master() and server_time - time > delta:
			time = server_time
	
	Network_tick(delta)

func Network_tick(delta):
	if not get_tree().has_network_peer():
		return
	if not is_network_master():
		return
	
	if network_tick <= 0:
		network_tick = NETWORK_TICK_RATE
		rpc_unreliable("update_time", time)
	else:
		network_tick -= delta

remote func update_time(s_time):
	server_time = s_time

func gerstFRec(k,x,c,a,i):
	if i == 0:
		return k * (x - c*time)
	return k * (x-a*cos(gerstFRec(k, x, c, a, i - 1)) - c*time)

func GerstnerWaveY(wave, x, z):
	var steepness = wave.z
	var wavelength = wave.w
	var d = wave.direction.normalized()
	var k = 2.0 * pi /wavelength
	var c = sqrt(9.8/k)
	var a = steepness / k
	
	#var f = k * (d.dot(Vector2(x,z)) - c*time)
	var dxz = d.dot(Vector2(x,z))
	return a * sin(gerstFRec(k,dxz,c,a,5))

func calculateWaveHeight(x, z):
	var y = 0
	for index in range(0, wave.size()):
		y += GerstnerWaveY(wave[index],x, z)
	return y

func addWave(x, y, steepness, amplitude):
	wave.append(vec4.new(Vector2(x, y), steepness, amplitude))

