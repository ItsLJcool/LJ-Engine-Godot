class_name BaseTransition extends Control

signal transition_complete(out:bool)

@onready var curtan:ColorRect = $Curtan
@onready var top_cover:TextureRect = $Curtan/TopCover
@onready var bottom_cover:TextureRect = $Curtan/BottomCover

var COVER_HEIGHT:int = 200:
	set(value):
		COVER_HEIGHT = clamp(value, 0, INF)
		if !top_cover and !bottom_cover: return
		top_cover.texture.height = COVER_HEIGHT
		bottom_cover.texture.height = COVER_HEIGHT

func game_ready():
	COVER_HEIGHT = COVER_HEIGHT
	visible = true
	set_process(false)

func prepare_transition(out:bool = false):
	position.y = -1280 - COVER_HEIGHT - 25 if !out else 0

func do_transition(out:bool = false):
	prepare_transition(out)
	var end_position:float = 1280 + COVER_HEIGHT if out else 0
	await FunkinGame.instance.create_tween().tween_property(self, "position:y", end_position, 0.75).finished
	transition_complete.emit(out)
