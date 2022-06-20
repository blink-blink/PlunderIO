extends Node


export var max_load_time = 10000

func load_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Resource loader unable to load the resource at path")
		return
	
	var loading_screen = load("res://Scenes/LoadingScreen.tscn").instance()
	var progress_bar = loading_screen.get_node("ProgressBar")
	
	get_tree().get_root().call_deferred("add_child",loading_screen)
	
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() - t < max_load_time:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			# loading complete
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred("add_child", resource.instance())
			current_scene.queue_free()
			loading_screen.queue_free()
			break
		elif err == OK:
			#still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			progress_bar.value = progress*100
		else:
			print("Error while loading file")
			break
		yield(get_tree(), "idle_frame")
