extends Control


export(NodePath) onready var chat_log = get_node(chat_log) as RichTextLabel
export(NodePath) onready var input_label = get_node(input_label) as Label
export(NodePath) onready var input_field = get_node(input_field) as LineEdit
onready var world = get_node("../")

var command_prefix: String = "/cmd "

var just_focused = false

func _ready():
	if get_tree().has_network_peer():
		set_visible(true)

func _input(event):
	if event.is_action_pressed("ui_accept") and not input_field.has_focus():
		input_field.grab_focus()
		just_focused = true
	if event.is_action_pressed("ui_cancel") and input_field.has_focus():
		input_field.release_focus()

remotesync func add_message(username, text):
	chat_log.bbcode_text += "Player " + str(username) + ': '
	chat_log.bbcode_text += text + '\n'

remotesync func enter_command(cmd: String):
	var player = world.get_node(str(get_tree().get_network_unique_id()))
	
	print("Command entered: " + cmd)
	
	if cmd.begins_with("change_boat ") and player:
		print("Command change_boat detected")
		player.rpc("change_boat", cmd.trim_prefix("change_boat "))
	if cmd.begins_with("full_health"):
		pass

func _on_LineEdit_text_entered(text: String):
	if just_focused:
		just_focused = false
		return
	
	if text == "":
		return

	input_field.text = ""
	input_field.release_focus()
	
	if text.begins_with(command_prefix):
		enter_command(text.trim_prefix(command_prefix))
	else:
		rpc("add_message",get_tree().get_network_unique_id(), text)
