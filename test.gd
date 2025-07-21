extends Node2D

var testNote = preload("res://Funkin/Game/Note.tscn")

@onready var player:StrumLine = $StrumLine

func _ready() -> void:
	
	var song = Song.new()
	song.init("linkbite")
	add_child(song)
	Conductor.intro(0)
	Song.codenameParse("linkbite", "hard", [player])
