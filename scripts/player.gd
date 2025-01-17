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

var crow : Crow

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed := 0
var dir := Vector2.RIGHT
var is_hidden := false
var can_jump := true
var crow_summoned := false
var animation_lock := false

func _ready():
	crow = load("res://objects/crow.tscn").instantiate()
	self.add_child(crow)
	crow.start(self, crow_summoned)

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
	if Input.is_action_just_pressed("toggle_crow"):
		if crow_summoned:
			crow.fly_away()
		else:
			crow.to_player()
		crow_summoned = not crow_summoned
	
	if crow_summoned:
		if Input.is_action_just_pressed("interact"):
			crow.fly_to(get_global_mouse_position())
	else:
		if Input.is_action_just_pressed("interact") and interact_area.has_overlapping_areas() and interact_area.get_overlapping_areas()[0] is Interactable:
			interact_area.get_overlapping_areas()[0].interact(self)
			self.velocity = Vector2.ZERO
		elif Input.is_action_just_pressed("bite") and interact_area.has_overlapping_areas() and interact_area.get_overlapping_areas()[0] is Biteable:
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
	if animation_lock and not sprite.is_playing():
		animation_lock = false
	elif animation_lock:
		return
	
	if Input.is_action_just_pressed("bite"):
		sprite.play("bite")
		animation_lock = true
	elif Input.is_action_just_pressed("attack"):
		sprite.play("tailslap_back")
		animation_lock = true
	elif Input.is_action_pressed("jump") and can_jump:
		sprite.play("jump")
	elif not is_on_floor():
		sprite.play("in_air")
	elif velocity.x != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
