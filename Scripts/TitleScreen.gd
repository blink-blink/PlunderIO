extends Control

onready var Buttons = $VBoxContainer/CenterRow/Buttons
var loading_screen = preload("res://Scenes/LoadingScreen.tscn")

func _ready():
	pass
#	for button in Buttons.get_children():
#		print(button.scene)
#		button.connect("pressed", self, "_on_Button_pressed", [button.scene])

#func _on_Button_pressed(scene):
#	print("pressed")


func _on_NewGameButton_pressed():
	SceneLoader.load_scene(Buttons.get_node("NewGameButton").scene, self)
	Global.add_player(get_tree().get_network_unique_id())

func _on_LocalMultButton_pressed():
	get_tree().change_scene("res://Scenes/NetworkSetup.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
