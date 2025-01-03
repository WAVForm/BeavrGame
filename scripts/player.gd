extends CharacterBody2D

class_name Player

@export_category("Movement")
@export var max_speed := 300.0
@export var min_speed := 50.0
@export var accel := 15
@export var decel := 20
@export var jump_force := 500.0

@onready var interact_area = $interactable_area
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

enum STATES {IDLE, STOPPING, MOVING, JUMPING, FALLING, HIDING, HIDDEN}
var current_state:STATES = STATES.IDLE
var speed := 0
var dir := Vector2.RIGHT

func _process(_delta):
	dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_down", "look_up")) #get direction for current frame

func _physics_process(delta):
	try_move(delta)
	try_interaction()
	
func try_move(delta):
	if current_state == STATES.HIDING or current_state == STATES.HIDDEN:
		return

	if is_on_floor() and dir.x == 0 and not Input.is_action_just_pressed("jump") and velocity.x == 0:
		current_state = STATES.IDLE
		return
	
	if dir.x != 0:
		current_state = STATES.MOVING
		if velocity.x < 0 and dir.x > 0 or velocity.x > 0 and dir.x < 0:
			velocity.x *= -1
		velocity.x += (dir.x*accel) if velocity.x < max_speed and velocity.x > -max_speed else 0.0
	elif velocity.x != 0:
		current_state = STATES.STOPPING
		if velocity.x < 0 and velocity.x > -min_speed or velocity.x > 0 and velocity.x < min_speed:
			velocity.x = 0
			current_state = STATES.IDLE
		else:
			velocity.x -= decel * (1 if velocity.x > 0 else -1)
	
	if not is_on_floor():
		current_state = STATES.FALLING
		velocity.y += gravity * delta #gravity
	elif Input.is_action_just_pressed("jump"):
		current_state = STATES.JUMPING
		velocity.y -= jump_force

	move_and_slide()

func try_interaction():
	if Input.is_action_just_pressed("interact") and interact_area.has_overlapping_areas():
		interact_area.get_overlapping_areas()[0].interact(self)
