class_name BaseTransition extends Control

signal transition_complete(out:bool)

@onready var curtan:ColorRect = $Curtan
@onready var cover:TextureRect = $Curtan/Cover

func game_ready():
	visible = true
	set_process(false)
	prepare_transition(false)

func prepare_transition(out:bool = false):
	curtan.size = FunkinGame.window.size
	cover.size.y = curtan.size.x
	
	if out:
		curtan.position.y = 0
		
		cover.position.y = -cover.texture.get_width()
		cover.flip_h = true
	else:
		curtan.position.y = -FunkinGame.window.size.y - cover.texture.get_width()
		
		cover.position.y = curtan.size.y
		cover.flip_h = false

func transition_in(time:float = 0.5):
	prepare_transition(false)
	var twn = FunkinGame.instance.create_tween()
	twn.tween_property(curtan, "position:y", 0, time)
	await twn.finished
	transition_complete.emit(false)

func transition_out(time:float = 0.5):
	prepare_transition(true)
	var twn = FunkinGame.instance.create_tween()
	twn.tween_property(curtan, "position:y", FunkinGame.window.size.y + cover.texture.get_width(), time)
	await twn.finished
	transition_complete.emit(true)
