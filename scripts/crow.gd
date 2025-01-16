extends Node2D

class_name Crow

@onready var sprite := $sprite
@onready var search_area :Area2D= $search_area
var player: Player
var start_pos : Vector2
var target_pos : Vector2
@export var speed := 500 #?
@export var max_search_time = 3.0 #seconds
var current_time := 0.0
enum STATES {NONE, FOLLOW_PLAYER, TO_TARGET, WAIT, TO_PLAYER}
var current_state := STATES.NONE

func start(p_ref):
	player = p_ref
	self.global_position = player.get_node("crow_spot").global_position

func fly_to(pos):
	if current_state == STATES.NONE:
		self.reparent(player.get_parent(), true)
		start_pos = player.global_position
		target_pos = pos
		current_state = STATES.TO_TARGET
		if start_pos.x < target_pos.x:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
		sprite.play("fly")
	
func _physics_process(delta):
	match current_state:
		STATES.NONE:
			return
		STATES.TO_TARGET:
			self.global_position = self.global_position.move_toward(target_pos, delta*speed)
			if self.global_position.is_equal_approx(target_pos):
				current_state = STATES.WAIT
		STATES.WAIT:
			current_time += delta
			#search around?
			if search_area.has_overlapping_areas():
				start_pos = self.global_position
				target_pos = search_area.get_overlapping_areas()[0].global_position
				if start_pos.x < target_pos.x:
					sprite.scale.x = 1
				else:
					sprite.scale.x = -1
				current_time = 0.0
				current_state = STATES.TO_TARGET
			if current_time >= max_search_time:
				start_pos = self.global_position
				current_time = 0.0
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
