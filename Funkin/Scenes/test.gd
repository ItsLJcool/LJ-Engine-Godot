extends Node2D

@onready var player:StrumLine = $UILayer/Player
@onready var cpu:StrumLine = $UILayer/Cpu

var song_name:String = "last-embed"

func _ready() -> void:
	var testCharacter = Character.new()
	add_child(testCharacter)
	player.add_character(testCharacter)
	
	testCharacter.position = FunkinGame.window.size * 0.5
	
	var song = Song.new()
	song.init(song_name)
	add_child(song)
	Conductor.intro(0)
	Song.codenameParse(song_name, "hard", [cpu, player])
