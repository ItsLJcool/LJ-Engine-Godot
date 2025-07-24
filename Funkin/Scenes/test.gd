extends Node2D

@onready var player:StrumLine = $UILayer/Player
@onready var cpu:StrumLine = $UILayer/Cpu

var song_name:String = "last-embed"

func _ready() -> void:
	var testCharacter = Character.new()
	add_child(testCharacter)
	testCharacter.position.x = 720
	player.add_character(testCharacter)
	
	var song = Song.new()
	song.init(song_name)
	add_child(song)
	Conductor.intro(0)
	Song.codenameParse(song_name, "hard", [cpu, player])
	
	FunkinGame.camera.position.x = 100
