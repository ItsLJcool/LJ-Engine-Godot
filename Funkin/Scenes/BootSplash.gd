class_name BaseBootSplash extends Node2D

@onready var top_color:ColorRect = $UILayer/EndIt/ColorRect

const NEXT_STATE:PackedScene = preload("res://Funkin/Scenes/PlayState.tscn")

func _ready() -> void:
	top_color.visible = true
	pass

func scene_ready():
	await get_tree().create_timer(0.25).timeout
	await create_tween().tween_property(top_color, "self_modulate:a", 0, 0.5).finished
	await get_tree().create_timer(1.5).timeout
	finished()

var leaving:bool = false
func finished():
	if leaving: return
	leaving = true
	await create_tween().tween_property(top_color, "self_modulate:a", 1, 0.5).finished
	FunkinGame.switch_state(NEXT_STATE, true)

func _input(event: InputEvent) -> void:
	if event is not InputEventKey: return
	
	if event.keycode == KEY_ENTER: finished()
