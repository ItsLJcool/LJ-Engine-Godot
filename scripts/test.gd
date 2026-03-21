extends Node2D

var player_strum:StrumLine

var song_name:String = "bergadam sandler"
var diff:String = "hard"

var chart:Chart = Chart.from_cne_chart(song_name, diff)

@onready var ui_layer:CanvasLayer = $UILayer

var temp_char:Character = Character.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.add_audio_to_sync(load("res://assets/songs/%s/song/Inst.ogg" % song_name) as AudioStreamOggVorbis)
	
	for suffix in chart.get_vocals(): Conductor.add_audio_to_sync(load("res://assets/songs/%s/song/Voices%s.ogg" % [song_name, suffix]))
	
	player_strum = StrumLine.new(chart.strumlines[1])
	player_strum.cpu = false
	player_strum.on_note_hit.connect(on_note_hit)
	ui_layer.add_child(player_strum)
	
	temp_char.position = Vector2(1920 * 0.5, 1080 * 0.5)
	add_child(temp_char)
	
	Conductor.bpm = chart.meta.bpm
	Conductor.play()


func on_note_hit(note:Note):
	temp_char.play_sing_anim(note.dir)
	temp_char.last_hit += note.sus_length
