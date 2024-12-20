extends Control

@onready var visual = $split/visual
@onready var text = $split/text_container
@onready var text_background = $split/text_container/background
@onready var text_content = $split/text_container/text

var blank := Color(0,0,0,0)
var start := false

func _ready():
	visual.modulate = blank
	text.modulate = blank
	text_background.modulate = blank
	text_content.visible_ratio = 0

func _process(delta):
	if start:
		
