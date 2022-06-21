extends Control

onready var mutliplayer_config_ui = $MultiplayerConfigure
onready var server_ip_address = $MultiplayerConfigure/ServerIPAdress
onready var device_ip_address = $DeviceIPAddress

var world_scene_path = "res://Scenes/World.tscn"
var player = load("res://Scenes/Player.tscn")

func _ready():
	device_ip_address.text = Network.ip_address

func _on_Back_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")

func _on_CreateServer_pressed():
	mutliplayer_config_ui.hide()
	Network.create_server()
	SceneLoader.load_scene(world_scene_path, self)

func _on_JoinServer_pressed():
	if server_ip_address.text != "":
		mutliplayer_config_ui.hide()
		Network.ip_address = server_ip_address.text
		Network.is_joining_server = true
		SceneLoader.load_scene(world_scene_path, self)
