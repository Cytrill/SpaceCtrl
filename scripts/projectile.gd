
extends RigidBody2D

var damage = 1
var player = null

func _ready():
	pass

	#Kollision?
func _integrate_forces(state):
	
	if (state.get_contact_count() > 0):
		
		for i in range (state.get_contact_count()):
			var contact_object = state.get_contact_collider_object(i)  
			contact_object.get_groups()
			if ("Ships" in contact_object.get_groups()):
				contact_object.damage(damage)
				if (player != null):
					player.score+=1
					get_node("/root/Space").highscore[player.get_name()] = player.score
			self.queue_free()
