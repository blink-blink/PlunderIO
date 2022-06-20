extends Node

var Players = []

func add_player(id):
	Players.append(id)

func remove_player(id):
	Players.erase(id)
