extends Area2D

const MOTION_SPEED = 160 # Pixels/second.

var is_falling
var screen_size 

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var motion = Vector2()
	
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	
	if(is_falling):
		$CollisionShape2D.set_deferred("disabled", true)
		z_index = -1
		motion.y = 1
	
	motion = motion.normalized() * MOTION_SPEED
	
	position += motion * delta
	position = position.clamp(Vector2.ZERO, screen_size)

 
func _on_body_entered(body):
	is_falling = false


func _on_body_exited(body):
	is_falling = true
