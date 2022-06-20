extends Control

export(NodePath) onready var chatbox_lineedit = get_node(chatbox_lineedit) as LineEdit

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not has_focus() and not chatbox_lineedit.has_focus():
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			set_visible(true)
			grab_focus()
		elif has_focus():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			set_visible(false)
			release_focus()


func _on_QuitGame_pressed():
#	if get_tree().has_network_peer():
#		get_tree().get_network_peer().close_connection()
#
#	Global.Players.clear()
#	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
#
#	var root = get_tree().get_root()
#	var world = root.get_node("World")
#	root.remove_child(world)
#	world.call_deferred("free")

	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
	var world = get_tree().get_root().get_node("World")
	world.quit_game()
