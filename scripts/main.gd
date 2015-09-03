
extends Node2D

var time_elapsed = 0

var game_time = 120 #In Seconds
var timeout_time = 2 #In Seconds
var time_remaining = game_time

var game_state_prev = ""
var game_state = ""
var game_state_next = "timeup"

var fight_dialog_time = 2 #In Seconds

var pl_player = preload("res://PlayerShip.scn")

var texture_count = 6 #the amount of individual Ship-Textures

var highscore = {}

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	time_elapsed+=delta
	game_state_prev = game_state
	game_state = game_state_next
	
	if (game_state == "running"):
		state_running(delta)
	
	if (game_state == "timeup"):
		state_timeup(delta)
	
func state_running(delta):
	if (game_state_prev != "running"):
		time_elapsed = 0 #Reset Timer
		#Activate Ships:
		for player in get_node("Players").get_children():
			player.player_controlled = true
		get_node("HUD/LGo").show()
		
	
	time_remaining = game_time - time_elapsed
	
	if (time_elapsed > fight_dialog_time):
		get_node("HUD/LGo").hide()
	
	if (time_remaining <= 0):
		game_state_next = "timeup"
	else:
		var m = floor(time_remaining / 60)
		var s = (int(floor(time_remaining)) % 60)
		
		get_node("HUD/LTime").set_text(str(m) + ":" + str(s))
	
func state_timeup(delta):
	if (game_state_prev != "timeup"):
		print(highscore.size())
		time_elapsed = 0 #Reset Timer
		
		#Display Highscore
		var str_highscore = "HIGHSCORE:\n"
		
		for p in highscore:
			print("HIGHSCORE: " + p)
			str_highscore += p + ": "  + str(highscore[p])+"\n"
			
		get_node("GUIJoinGame/LHighscore").set_text(str_highscore)
		highscore = {} #Reset Highscore
		
		#Remove all Players
		for player in get_node("Players").get_children():
			player.queue_free()
		
	#Start countdown after two Players have joined the game:
	if (get_node("Players").get_child_count() > 1):
		time_remaining = timeout_time - time_elapsed
	else:
		time_remaining = timeout_time
	
	if (time_remaining <= 0):
		get_node("GUIJoinGame").hide()
		
		game_state_next = "running"
	else:
		var m = floor(time_remaining / 60)
		var s = (int(floor(time_remaining)) % 60)
		
		get_node("HUD/LTime").set_text(str(m) + ":" + str(s))
		
		#show Join-GUI
		get_node("GUIJoinGame").show()
		
	#Check if a Player wants to join the game:
	for i in range(1,99):
		if (Input.is_action_pressed("Player"+ str(i) + "_Fire")):
			if (!get_node("Players").has_node("Player"+str(i))):
				#Reset countdown after two Players have joined the game:
				if (get_node("Players").get_child_count() == 1):
					time_elapsed = 0 #Reset Timer
				print("Player " + str(i) + " has joined the game!")
				var player = pl_player.instance()
				player.set_name("Player"+str(i))
				highscore["Player"+str(i)] = 0 #Init Playerscore
				var texture_index = i
				
				if (texture_index > texture_count):
					 texture_index = (i % texture_count)+1
				var t = load("res://gfx/Player" + str(i) + ".png")
				player.add_to_group("Ships")
				var color = Color(1,1,1)
				color.s = 1
				color.h = i*0.05 #Change Hue using player index
				player.get_node("Sprite").set_modulate(color)
				player.get_node("Sprite").set_texture(t)
				get_node("Players").add_child(player)
			
	print(highscore)
	
	