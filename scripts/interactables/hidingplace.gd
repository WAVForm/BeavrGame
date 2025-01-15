extends Interactable

class_name HidingPlace

@export_category("Hiding")
@export var hiding_time = 0.1

enum STATES {NONE, HIDING, HIDDEN, UNHIDING}
var current_state := STATES.NONE
var current_time := 0.0
var p_ref:Player = null

func _physics_process(delta):
	match current_state:
		STATES.NONE:
			pass
		STATES.HIDDEN:
			pass
		STATES.HIDING:
			if current_time >= hiding_time:
				p_ref.position = self.global_position
				p_ref.modulate = Color(Color.BLACK, 0.5)
				p_ref.is_hidden = true
				current_state = STATES.HIDDEN
				current_time = 0.0
			else:
				current_time += delta
				p_ref.position = lerp(p_ref.position, self.global_position, current_time/hiding_time)
				p_ref.modulate = lerp(Color.WHITE, Color(Color.BLACK, 0.5), current_time/hiding_time)
		STATES.UNHIDING:
			if current_time >= hiding_time:
				p_ref.modulate = Color.WHITE
				p_ref.is_hidden = false
				p_ref.move_and_slide()
				p_ref = null
				current_state = STATES.NONE
				current_time = 0.0
			else:
				current_time += delta
				p_ref.modulate = lerp(Color(Color.BLACK, 0.5), Color.WHITE, current_time/hiding_time)

func interact(player:Player):
	match current_state:
		STATES.NONE:
			current_state = STATES.HIDING
			p_ref = player
		STATES.UNHIDING:
			current_state = STATES.HIDING
			p_ref = player
		STATES.HIDDEN:
			current_state = STATES.UNHIDING
			p_ref = player
		STATES.HIDING:
			current_state = STATES.UNHIDING
			p_ref = player
