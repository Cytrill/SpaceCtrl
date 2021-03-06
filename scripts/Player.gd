
extends RigidBody2D

export var player_controlled = false
export var score = 0
var player_number = 0

var nose_norm = Vector2(0,0)
var thrust = 1.2
var pl_projectile = preload("res://projectile.scn")
var pl_explosion = preload("res://explosion.scn")

var projectile = null
var projectile_speed = 400
var cooldown_shoot = 0
var cooldown_shoot_default = .8
var hitpoints = 1
var hitpoints_max = 1

var invincible = false
var cooldown_invincible = 0
var cooldown_invincible_default = 2

var joy_tresh = 0.2


func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (cooldown_shoot > 0):
		cooldown_shoot -= delta
	if (cooldown_invincible >= 0):
		cooldown_invincible -= delta
	else:
		cooldown_invincible = 0

	if (cooldown_invincible > 0):
		set_collision_mask_bit( 0, false )
		get_node("Sprite").set_opacity(0.5+0.5*sin(cooldown_invincible*15))
	else:
		set_collision_mask_bit( 0, true )
		get_node("Sprite").set_opacity(1)
		
	nose_norm = Vector2(get_node("Nose").get_global_pos().x - get_pos().x, get_node("Nose").get_global_pos().y - get_pos().y).normalized()
	
	if (player_controlled):
		if Input.get_joy_axis(player_number,  1) < -joy_tresh:
			apply_impulse(Vector2(0,0),nose_norm*thrust)
			get_node("ThrustParticles").set_param(Particles2D.PARAM_DIRECTION ,get_rot())
			get_node("ThrustParticles").set_emitting(true)
			
		if Input.get_joy_axis(player_number,  0) < -joy_tresh:
			set_rot(get_rot()+.03)
		if Input.get_joy_axis(player_number,  0) > joy_tresh:
			set_rot(get_rot()-.03)
			
		if (player_controlled && Input.is_joy_button_pressed(player_number,  1) && cooldown_shoot+cooldown_invincible <= 0):
			projectile = pl_projectile.instance()
			projectile.set_pos(get_pos() + nose_norm*64)
			projectile.set_rot(get_rot())
			projectile.player = self
			projectile.apply_impulse(Vector2(0,0),nose_norm*projectile_speed)
			get_node("/root/Space").add_child(projectile)
			cooldown_shoot = cooldown_shoot_default
		
	
	#Falls der Spieler den Bildschirm verlässt soll er auf der gegenüberliegendenden Seite erscheinen
	if (get_pos().x > 1920):
		set_pos(Vector2(0,get_pos().y))
	if (get_pos().x < 0):
		set_pos(Vector2(1920,get_pos().y))
	if (get_pos().y < 0):
		set_pos(Vector2(get_pos().x, 1080))
	if (get_pos().y > 1080):
		set_pos(Vector2(get_pos().x, 0))
		
func damage(amount):
	get_node("ExplosionParticles").set_emitting(true)
	hitpoints -= amount
	if (hitpoints <= 0):
		var explosion = pl_explosion.instance()
		explosion.set_pos(get_pos())
		get_node("/root/Space").add_child(explosion)
		explosion = null
		#set_pos(Vector2(randf()*get_viewport_rect().size.x,randf()*get_viewport_rect().size.y))
		hitpoints = hitpoints_max
		# invincible for a few seconds..
		cooldown_invincible = cooldown_invincible_default
		#self.queue_free()

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		#turn off LEDs on quit:
		cytrill.set_led(player_number, 0, 0, 0, 0, 0)
		cytrill.set_led(player_number, 1, 0, 0, 0, 0)
		
		get_tree().quit() # default behavior