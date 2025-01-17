extends Node2D

class_name Crow

@onready var sprite := $sprite
@onready var search_area :Area2D= $search_area
@onready var wait_timer := $wait_timer

var player: Player
var start_pos : Vector2
var target_pos : Vector2
@export var speed := 500 #?
enum STATES {NONE, FOLLOW_PLAYER, TO_TARGET, WAIT, TO_PLAYER, OFF_SCREEN}
var current_state := STATES.NONE

func start(p_ref, summoned):
	player = p_ref
	if not summoned:
		self.position = (get_viewport_rect().size * 0.5) * -1
		self.position.y -= 48
	else:
		self.position = player.get_node("crow_spot").position

func fly_to(pos):
	if current_state == STATES.NONE:
		start_pos = player.global_position
		target_pos = pos
		current_state = STATES.TO_TARGET
		sprite.play("fly")
		
func to_player():
	current_state = STATES.TO_PLAYER
	start_pos = (get_viewport_rect().size * 0.5) * -1
	sprite.play("fly")

func fly_away():
	start_pos = self.global_position
	target_pos = ((get_viewport_rect().size * 0.5) * -1)
	target_pos.y -= 48
	if start_pos.x < target_pos.x:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	current_state = STATES.OFF_SCREEN
	sprite.play("fly")

func _physics_process(delta):
	match current_state:
		STATES.NONE:
			return
		STATES.TO_TARGET:
			if start_pos.x < target_pos.x:
				sprite.scale.x = 1
			else:
				sprite.scale.x = -1
			self.global_position = self.global_position.move_toward(target_pos, delta*speed)
			if self.global_position.is_equal_approx(target_pos):
				wait_timer.start()
				self.reparent(player.get_parent(), true)
				current_state = STATES.WAIT
		STATES.WAIT:
			#search around?
			if search_area.has_overlapping_areas():
				start_pos = self.global_position
				target_pos = search_area.get_overlapping_areas()[0].global_position
				if start_pos.x < target_pos.x:
					sprite.scale.x = 1
				else:
					sprite.scale.x = -1
				current_state = STATES.TO_TARGET
			if wait_timer.is_stopped():
				start_pos = self.global_position
				current_state = STATES.TO_PLAYER
		STATES.TO_PLAYER:
			target_pos = player.get_node("crow_spot").global_position
			if start_pos.x < target_pos.x:
				sprite.scale.x = 1
			else:
				sprite.scale.x = -1
			self.global_position = self.global_position.move_toward(target_pos, delta*speed)
			if self.global_position.is_equal_approx(target_pos):
				self.reparent(player, true)
				sprite.play("idle")
				current_state = STATES.NONE
		STATES.OFF_SCREEN:
			self.position = self.position.move_toward(target_pos, delta*speed)
			if self.position.is_equal_approx(target_pos):
				sprite.play("idle")
				current_state = STATES.NONE
