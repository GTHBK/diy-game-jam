class_name StartMenu
extends Node2D


onready var start_button: Button = $Start


func _ready():
	Sound.play_sound("opening")
	assert(start_button.connect("pressed", self, "game_start") == OK)
	#game_node.play_sound("opening")

func game_start():
	print("Are you ready?")
	Game.change_scene("opening", "level_select")
