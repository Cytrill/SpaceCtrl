
extends Particles2D

var time_elapsed = 0

func _ready():
	set_emitting(true)
	set_process(true)
	
	
func _process(delta):
	time_elapsed+=delta
	if (time_elapsed > get_emit_timeout() + get_lifetime()):
		self.queue_free()
		

