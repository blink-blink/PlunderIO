extends Node

var ship_data = {
		"Dummy": {
			"scene": preload("res://Scenes/BoatDummy.tscn"),
			"camscale": 1},
		"Schooner": {
			"scene": preload("res://Scenes/BoatSchooner.tscn"),
			"camscale": 1},
		"ManOWar": {
			"scene": preload("res://Scenes/BoatManOWar.tscn"),
			"camscale": 1.5}
			}

var mob_scene = {	
	"Dummy": preload("res://Scenes/MobDummy.tscn"),
	"ManOWar": preload("res://Scenes/MobManOWar.tscn"),
}
