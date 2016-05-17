
extends Node2D

var time_elapsed = 0

var game_time = 120 #In Seconds
var timeout_time = 20 #In Seconds
var time_remaining = game_time

var game_state_prev = ""
var game_state = ""
var game_state_next = "timeup"

var fight_dialog_time = 3 #In Seconds

var pl_player = preload("res://PlayerShip.scn")

var texture_count = 6 #the amount of individual Ship-Textures

var highscore = {}

#Player Colors
const colarray = [Color(0, 0, 1), Color(0, 1, 0), Color(0, 1, 1),
	Color(1, 0, 0), Color(1, 0, 1), Color(1, 1, 0), Color(1, 1, 1), Color(1, 0, 0)]


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
		

	for i in range(0,128):
		if Input.is_joy_button_pressed(i, 0):
			if (!get_node("Players").has_node(cytrill.get_name(i))):
				print("Button has been presed!")
				#Reset countdown after two Players have joined the game:
				if (get_node("Players").get_child_count() == 1):
					time_elapsed = 0 #Reset Timer
				
				print(cytrill.get_name(i)+ " has joined the game!")
				var player = pl_player.instance()
				player.set_name(cytrill.get_name(i))
				player.player_number = i
				highscore[cytrill.get_name(i)] = 0 #Init Playerscore
				var texture_index = (i+1)
				
				if (texture_index > texture_count):
					 texture_index = (i % texture_count)+1
				var t = load("res://gfx/Player" + str(texture_index) + ".png")
				player.add_to_group("Ships")
				var color = Color(1,1,1)
				color.s = 1
				color.h = i*0.05 #Change Hue using player index
				cytrill.set_led(i, 0, colarray[i%8].r*255, colarray[i%8].g*255, colarray[i%8].b*255, 2)
				cytrill.set_led(i, 1, colarray[i%8].r*255, colarray[i%8].g*255, colarray[i%8].b*255, 2)
				player.get_node("Sprite").set_modulate(colarray[i%8])
				player.get_node("Sprite").set_texture(t)
				get_node("Players").add_child(player)
			
	print(highscore)
	
	