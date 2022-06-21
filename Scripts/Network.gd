extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""
var is_joining_server = false

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168") and not ip.ends_with(".1"):
			ip_address = ip
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	Global.add_player(get_tree().get_network_unique_id())

func join_server():
	is_joining_server = false
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func disconnect_to_server():
	if get_tree().has_network_peer():
		get_tree().get_network_peer().close_connection()
		get_tree().set_network_peer(null)
	
	Global.Players.clear()

func _connected_to_server():
	print("server connect success")
	Global.add_player(get_tree().get_network_unique_id())

func _server_disconnected():
	print("server disconnected")

func _player_connected(id):
	print("Player" + str(id) + " has connected")
	Global.add_player(id)

func _player_disconnected(id):
	print("Player" + str(id) + " has disconnected")
	
	Global.remove_player(id)
