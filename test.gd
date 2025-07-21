extends Node2D

var testNote = preload("res://Funkin/Game/Note.tscn")

@onready var player:StrumLine = $StrumLine


func _ready() -> void:
	
	var song = Song.new()
	song.play("linkbite")
	add_child(song)
	song.codenameParse("linkbite", "hard", [player])

	#player.add_note(0, 2500, 1000)

var amount:float = 20;
func _process(delta: float) -> void:
	return
	player.loop_for_strums(func(strum:Strum):
		control.x = -450 * (1 if strum.direction < 2 else -1)
		control.y = -1300;
		#control.x = sin((Conductor.song_position * 0.001) * 4) * 250
		#control.y = 1500 * (sin((Conductor.song_position * 0.001) * 4)) * 1
		#end.x = control.x * 0.25
		var pointsNew:Array[Vector2] = []
		for i in range(0, amount+1): pointsNew.push_back(getBezierTest(i/amount))
		strum.notePath.points = pointsNew
	)

var start:Vector2 = Vector2(0, 0)
var control:Vector2 = Vector2(-750, -750)
var end:Vector2 = Vector2(0, 1500)
func getBezierTest(t:float)->Vector2:
	var u = 1 - t;
	var x = (u * u) * start.x + 2 * u * t * control.x + (t * t) * end.x;
	var y = (u * u) * start.y + 2 * u * t * control.y + (t * t) * end.y;
	return Vector2(x, y);
