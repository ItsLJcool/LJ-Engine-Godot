extends Node2D

@onready var player:StrumLine = $UILayer/Player
@onready var cpu:StrumLine = $UILayer/Cpu

func _ready() -> void:
	
	var song = Song.new()
	song.init("linkbite")
	add_child(song)
	Conductor.intro(0)
	Song.codenameParse("linkbite", "hard", [cpu, player])

func _process(delta: float) -> void:
	FunkinGame.instance.camera.position.x -= delta * 25
