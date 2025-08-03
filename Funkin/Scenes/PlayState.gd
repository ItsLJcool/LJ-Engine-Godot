class_name PlayState extends Node2D

@onready var player:StrumLine = $UILayer/Player
@onready var cpu:StrumLine = $UILayer/Cpu

@onready var stage_manager:StageManager = $"Stage Manager"

var song_name:String = "linkbite"

var song:Song = Song.new()

func _ready() -> void:
	
	stage_manager.load_stage()
	
	var testCharacter = Character.create()
	player.add_character(testCharacter)
	stage_manager.add_character(testCharacter)
	
	add_child(song)
	song.init(song_name)
	song.codenameParse(song_name, "hard", [cpu, player])
	Conductor.intro(0)
