extends CharacterBody2D

@export var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@export_category("Movement")
@export var max_speed := 300.0
@export var accel := 5
@export var jump_force := 500.0

var speed := 0

func _physics_process(delta):
	#gravity
	velocity.y += gravity * delta
	
	try_move(delta)
	
func try_move(delta):
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		if velocity.x < 0 and dir > 0 or velocity.x > 0 and dir < 0:
			velocity.x = 0
		velocity.x += Input.get_axis("move_left", "move_right")*accel if (-max_speed < velocity.x and velocity.x < max_speed) else 0
	else:
		velocity.x = lerp(velocity.x, 0.0, 2*accel*delta)
	velocity.y -= jump_force if Input.is_action_pressed("move_jump") and self.is_on_floor() else 0
	
	move_and_slide()
	
