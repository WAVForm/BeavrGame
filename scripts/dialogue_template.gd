extends Control

@onready var visual:TextureRect = $split/visual
@onready var text:Panel = $split/text_container
@onready var text_content:RichTextLabel = $split/text_container/text
@onready var doubleclick_timer:Timer = $doubleclick_timer

enum STATES {NONE, FADING_IN, DISPLAYING_TEXT, WAITING_FOR_CLICK, FADING_OUT, DOUBLE_CLICKED}

var prev_state: STATES = STATES.NONE
var current_state:STATES = STATES.NONE
var current_time := 0.0
var texts: Array[String]

signal done

@export var fade_time := 0.5
@export var speedup_multiplier := 2.0

func _ready():
	visual.modulate.a = 0.0 #blank
	text.modulate.a = 0.0 #blank
	text_content.visible_ratio = 0

func start(texts_p:Array[String], image_p:Texture2D):
	texts = texts_p
	visual.texture = image_p
	current_state = STATES.FADING_IN

func _process(delta):
	if current_state > STATES.NONE:
		current_time += delta * (speedup_multiplier if Input.is_action_pressed("lmb_click") else 1) #update current time, with multiplier if LMB is being pressed

		#check for double click
		if Input.is_action_just_pressed("lmb_click"):
			if doubleclick_timer.is_stopped():
				doubleclick_timer.start()
			else:
				prev_state = current_state
				current_state = STATES.DOUBLE_CLICKED

		match current_state:
			STATES.FADING_IN:
				if(current_time > fade_time or is_equal_approx(current_time, fade_time)): #if done fading in
					visual.modulate.a = 1.0 #make opaque
					text.modulate.a = 1.0 #make opaque
					current_time = 0.0 #reset time
					text_content.text = texts.pop_front() #set first text
					prev_state = STATES.FADING_IN
					current_state = STATES.DISPLAYING_TEXT
				else:
					var amt = current_time / fade_time #fade amount = % of time left
					visual.modulate.a = lerp(0.0, 1.0, amt) #fade
					text.modulate.a = lerp(0.0, 1.0, amt) #fade
			STATES.DISPLAYING_TEXT:
				var amt = current_time / text_content.get_line_count() #amount of text shown, 1 second per line
				if (amt > 1.0 or is_equal_approx(amt, 1.0)): #if all lines show
					text_content.visible_ratio = 1.0 #make sure they show
					current_time = 0.0 #reset time
					prev_state = STATES.DISPLAYING_TEXT
					current_state = STATES.WAITING_FOR_CLICK
				else:
					text_content.visible_ratio = amt #display correct amount of text
			STATES.WAITING_FOR_CLICK:
				if Input.is_action_pressed("lmb_click"): #if just clicked
					current_time = 0.0 #reset time
					prev_state = STATES.WAITING_FOR_CLICK
					if texts.size() > 0: #if texts left to show
							text_content.visible_ratio = 0.0 #reset amount of text shown
							text_content.text = texts.pop_front() #set text to next
							current_state = STATES.DISPLAYING_TEXT
					else:
							current_state = STATES.FADING_OUT
			STATES.FADING_OUT:
				if(current_time > fade_time or is_equal_approx(current_time, fade_time)): #if done fading out
					visual.modulate.a = 0.0 #set to final value
					text.modulate.a = 0.0 #seet to final value
					current_time = 0.0 #reset time, not necessary
					prev_state = STATES.FADING_OUT
					current_state = STATES.NONE
					done.emit() #let whatever needs to know that the dialogue is done
				else:
					var amt = current_time / fade_time #fade amount = % of tiem left
					visual.modulate.a = lerp(1.0, 0.0, amt) #fade
					text.modulate.a = lerp(1.0, 0.0, amt) #fade
			STATES.DOUBLE_CLICKED:
				match prev_state:
					STATES.FADING_IN:
						visual.modulate.a = 1.0 #make opaque
						text.modulate.a = 1.0 #make opaque
						current_time = 0.0 #reset time
						text_content.text = texts.pop_front() #set first text
						prev_state = STATES.FADING_IN
						current_state = STATES.DISPLAYING_TEXT
					STATES.DISPLAYING_TEXT:
						prev_state = STATES.DISPLAYING_TEXT
						if (texts.size() > 0):
							text_content.visible_ratio = 1.0 #make opaque
							current_time = 0.0 #reset time
							current_state = STATES.WAITING_FOR_CLICK
						else:
							current_state = STATES.FADING_OUT
					STATES.FADING_OUT:
						visual.modulate.a = 0.0 #set to final value
						text.modulate.a = 0.0 #seet to final value
						current_time = 0.0 #reset time, not necessary
						prev_state = STATES.FADING_OUT
						current_state = STATES.NONE
						done.emit() #let whatever needs to know that the dialogue is done
