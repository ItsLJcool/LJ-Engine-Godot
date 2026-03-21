class_name MultiAudioStreamPlayer extends Node

signal on_finished

## An array of all the players in this class
var players:Array[AudioStreamPlayer] = []

## The Audio Bus for the streams
var audio_bus:StringName = &"Master":
	set(v):
		audio_bus = v
		for player:AudioStreamPlayer in players: player.bus = v

var playback_position:float = 0.0:
	set(v):
		playback_position = v
		for player:AudioStreamPlayer in players: player.seek(v)

func _init(...args:Array) -> void:
	for value:String in args: add_new_player(value)

func add_new_player(path:String):
	var player:AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = audio_bus
	
	players.push_back(player)
	add_child(player)

var paused:bool = true:
	set(v):
		paused = v
		for player:AudioStreamPlayer in players: player.stream_paused = v

## Just returns a [bool] if our position is above 0
var has_started:bool:
	get: return playback_position > 0

func play(from_position:float = 0.0) -> void:
	for player:AudioStreamPlayer in players: player.play(from_position)

func stop() -> void:
	for player:AudioStreamPlayer in players: player.stop()

func finished() -> void:
	stop()
	playback_position = 0
	on_finished.emit()
