extends Node

@onready var canvas_layer:CanvasLayer = $CanvasLayer

@onready var sound_tray:BaseSoundTray = $CanvasLayer/SoundTray
@onready var fps_counter:RichTextLabel = $CanvasLayer/FPS

func _ready() -> void:
	canvas_layer.layer = 128
