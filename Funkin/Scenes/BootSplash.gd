class_name BaseBootSplash extends Node2D

@onready var temp_icon:Sprite2D = $Icon
@onready var temp_text:RichTextLabel = $Text

@onready var top_color:ColorRect = $ColorRect

const NEXT_STATE:PackedScene = preload("res://Funkin/Scenes/MainTesting.tscn")

func _ready() -> void:
	var icon_size:Vector2 = (temp_icon.texture.get_size() * temp_icon.scale)
	temp_icon.position = FunkinGame.window.size * 0.5
	temp_text.position.x = temp_icon.position.x - icon_size.x + 25
	temp_text.position.y = temp_icon.position.y + icon_size.y * 0.5
	
	top_color.size = FunkinGame.window.size

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
