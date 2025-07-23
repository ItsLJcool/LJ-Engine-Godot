extends Node2D

@onready var player:StrumLine = $UILayer/Player
@onready var cpu:StrumLine = $UILayer/Cpu

func _ready() -> void:
	var testCharacter = Character.new()
	add_child(testCharacter)
	testCharacter.position.x = 720
	player.add_character(testCharacter)
	
	var song = Song.new()
	song.init("linkbite")
	add_child(song)
	Conductor.intro(0)
	Song.codenameParse("linkbite", "hard", [cpu, player])
	
