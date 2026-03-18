extends Node2D

var player_strum:StrumLine

var song_name:String = "bergadam sandler"
var diff:String = "hard"

var chart:Chart = Chart.from_cne_chart(song_name, diff)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Conductor.audio_stream = (load("res://assets/songs/%s/song/Inst.ogg" % song_name) as AudioStreamOggVorbis)
	
	var temp:AudioStreamPlayer = AudioStreamPlayer.new()
	temp.stream = (load("res://assets/songs/%s/song/Voices.ogg" % song_name) as AudioStreamOggVorbis)
	temp.bus = Conductor.audio_bus
	Conductor.add_child(temp)
	
	#var temp2:AudioStreamPlayer = AudioStreamPlayer.new()
	#temp2.stream = (load("res://assets/songs/%s/song/VoicesZander.ogg" % song_name) as AudioStreamOggVorbis)
	#temp2.bus = Conductor.audio_bus
	#Conductor.add_child(temp2)
	
	player_strum = StrumLine.new(chart.strumlines[1])
	player_strum.cpu = false
	add_child(player_strum)
	
	#temp2.play()
	temp.play()
	Conductor.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
