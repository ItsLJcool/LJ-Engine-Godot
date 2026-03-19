extends Node2D

var player_strum:StrumLine

var song_name:String = "vreen vro"
var diff:String = "hard"

var chart:Chart = Chart.from_cne_chart(song_name, diff)

var vocals:MultiAudioStreamPlayer = MultiAudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.audio_stream = (load("res://assets/songs/%s/song/Inst.ogg" % song_name) as AudioStreamOggVorbis)
	
	for suffix in chart.get_vocals(): vocals.add_new_player("res://assets/songs/%s/song/Voices%s.ogg" % [song_name, suffix])
	vocals.audio_bus = Conductor.audio_bus
	add_child(vocals)
	for player:AudioStreamPlayer in vocals.players: Conductor.add_audio_to_sync(player.stream)
	
	player_strum = StrumLine.new(chart.strumlines[1])
	player_strum.cpu = false
	add_child(player_strum)
	
	vocals.play()
	Conductor.play()
	Conductor.on_conductor_finished.connect(func(): vocals.stop())
