
extends Node2D

var time_elapsed = 0

var game_time = 0.2*60 #In Seconds
var time_remaining = game_time

var game_state_prev = ""
var game_state = ""
var game_state_next = "running"

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	time_elapsed+=delta
	game_state_prev = game_state
	game_state = game_state_next
	
	if (game_state == "running"):
		state_running(delta)
	
func state_running(delta):
	
	time_remaining = game_time - time_elapsed
	
	if (time_remaining <= 0):
		game_state_next = "timeup"
	else:
		var m = floor(time_remaining / 60)
		var s = (int(floor(time_remaining)) % 60)
		
		get_node("GUI/LTime").set_text(str(m) + ":" + str(s))
	
	