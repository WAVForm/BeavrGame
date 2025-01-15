extends CharacterBody2D

class_name Player

@export_category("Movement")
@export var max_speed := 300.0
@export var min_speed := 50.0
@export var accel := 15
@export var decel := 20
@export var jump_force := 50
@export var jump_limit := 400 #max jump velocity

@onready var interact_area = $interactable_area
@onready var sprite = $sprite

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed := 0
var dir := Vector2.RIGHT
var is_hidden := false
var can_jump := true

func _process(_delta):
	dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_down", "look_up")) #get direction for current frame

func _physics_process(delta):
	try_move(delta)
	try_interaction()
	try_attack()
	try_sprite()
	
func try_move(delta):
	if is_hidden:
		return
	
	if is_on_floor() and dir.x == 0 and not Input.is_action_pressed("jump") and velocity.x == 0:
		return
	
	if dir.x != 0: #moving
		if velocity.x < 0 and dir.x > 0 or velocity.x > 0 and dir.x < 0:
			velocity.x = 0
		velocity.x += (dir.x*accel) if velocity.x < max_speed and velocity.x > -max_speed else 0.0
	elif velocity.x != 0: # stopping
		if velocity.x < 0 and velocity.x > -min_speed or velocity.x > 0 and velocity.x < min_speed:
			velocity.x = 0
		else:
			velocity.x -= decel * (1 if velocity.x > 0 else -1)
	
	if Input.is_action_just_released("jump") or self.velocity.y <= -jump_limit:
		can_jump = false
	if not can_jump and is_on_floor():
		can_jump = true
		
	if Input.is_action_pressed("jump") and can_jump:
		velocity.y -= jump_force
	elif not is_on_floor():
		can_jump = false
		velocity.y += gravity * delta #gravity

	move_and_slide()

func try_interaction():
	if Input.is_action_just_pressed("interact") and interact_area.has_overlapping_areas():
		interact_area.get_overlapping_areas()[0].interact(self)
		self.velocity = Vector2.ZERO
	elif Input.is_action_just_pressed("bite") and interact_area.has_overlapping_areas():
		interact_area.get_overlapping_areas()[0].bite(self)
		self.velocity = Vector2.ZERO

func try_attack():
	if Input.is_action_just_pressed("attack"):
		pass
	elif Input.is_action_just_pressed("bite"):
		pass
	
func try_sprite():
	if dir.x != 0:
		sprite.scale = Vector2(dir.x, 1)
	if is_hidden:
		return
		
	if Input.is_action_just_pressed("bite"):
		sprite.play("bite")
	elif Input.is_action_just_pressed("attack"):
		sprite.play("tailslap_back")
	elif Input.is_action_pressed("jump") and can_jump:
		sprite.play("jump")
	elif sprite.is_playing():
		return
	elif not is_on_floor():
		sprite.play("in_air")
	elif velocity.x != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
