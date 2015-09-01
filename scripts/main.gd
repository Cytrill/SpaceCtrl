
extends Node2D

var time_elapsed = 0

var game_time = 2 #In Seconds
var time_remaining = game_time

var game_state_prev = ""
var game_state = ""
var game_state_next = "running"

var pl_player = preload("res://PlayerShip.scn")

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
	
	time_remaining = game_time - time_elapsed
	
	if (time_remaining <= 0):
		game_state_next = "timeup"
	else:
		var m = floor(time_remaining / 60)
		var s = (int(floor(time_remaining)) % 60)
		
		get_node("HUD/LTime").set_text(str(m) + ":" + str(s))
	
func state_timeup(delta):
	if (game_state_prev == "running"):
		#Alle Spieler entfernen
		for player in get_node("Players").get_children():
			player.queue_free()
		
		#Join-GUI anzeigen
		get_node("GUIJoinGame").show()
		
	#Schauen ob ein Spieler das Spiel joinen möchte
	for i in range(1,99):
		if (Input.is_action_pressed("Player"+ str(i) + "_Fire")):
			if (!get_node("Players").has_node("Player"+str(i))):
				print("Player " + str(i) + " has joined the game!")
				var player = pl_player.instance()
				player.set_name("Player"+str(i))
				get_node("Players").add_child(player)
			
		
	
	