extends Node
## Basic Rhythm Game Conductor that is as optimised as can be in GDScript.[br]
##
## TODO: Make Linear BPM Changes 🙏

# Hi, LJ here!
# Im basing the implementation of this Conductor off of the Friday Night Funkin' Engine called: CodenameEngine
# I mainly referenced the math and how it works, but isn't a 1:1 copy of it, if you are thinking of it like that, It's not intentional.

# CNE's Conductor doesn't use the well known [60 / bpm] formula, but instead is based off of the idea called "Quarter note duration in milliseconds"
# The idea speaks to itself, as the [60 / bpm] is flawed in many ways but the 1 main flaw is that it isn't entirely accurate, because it's in seconds and not milliseconds.
# You have to convert the math into milliseconds by multiplying by 1,000 [(60 / bpm) * 1000] to get better precision in timing.

# This is why I opted into using this formula. It's more accurate which gives a more user-friendly experience.
# There is no formula name for what this Conductor does, so I decided to call it; "QuarterSeconds Conductor".
# I will explain the reasoning why we use this instead of the common method, and why you should also use this method instead.

# So, why did I even name the formula "QuarterSeconds Conductor"?
# I called it that, because it provides more precision to timings and more accurate BpmChanges if you implement them.
# Since everything is calculated at milliseconds, you can convert them back into seconds by just dividing 1,000 (or * 0.001 since it's more efficient) and you don't lose any quality when doing so!
# If we calculated everything in seconds, we'd lose floating point calculations when converting into milliseconds for more accurate timings. It's not a 2-way street.

# What does this formula achive?
# It attemps to achive ease of implementation without needing to actually think about how the Conductor works.
# If you want to use the formula effectively then you should implement BpmChanges (which this Conductor does)
# Why? It's because we can store everything related to `bpm`, `steps per beat`, `beats per measure` and even more data if needed as just a BpmChange.
# We consider the start of the song as a BpmChange with the default values, so that real BpmChanges can just slide in whenever.
# Since everything is in milliseconds, we don't need to convert betweeen 2 standard values which greatly improves readability and allows for more features, if needed.

# An example of features, is a Continuous Bpm Change.
# This conductor doesn't support it yet, but it is 100% possible to implement because we can linerally interpolate between different step times.
# This also means we can introduce Ease based Bpm Changes if we wanted to lol.

#region Bpm Changes Implementation
class BpmChange:
	## A [member dummy] instance of a "BpmChange". This is only used if we never change [member bpm].
	static var dummy:BpmChange = BpmChange.new()
	
	var bpm:float = 100.0 ## The remapped beats per minute for this change
	var song_time:float = 0.0 ## The MS in time where the bpm change occurs
	
	var step_time:float = 0.0 ## The time in steps this [member bpm] occurs. This is used to calculate the new steps from the change
	var beat_time:float = 0.0 ## The time in beats this [member bpm] occurs. This is used to calculate the new beats from the change
	var measure_time:float = 0.0 ## The time in measures this [member bpm] occurs. This is used to calculate the new measures from the change
	
	var steps_per_beat:int = 4 ## The new Steps Per Beat for this change
	var beats_per_measure:int = 4 ## The new Beats per Measure for this change
	
	var is_continuous:bool = false ## If this [member BpmChange] should be marked as a continuous change in tempo
	var end_song_time:float = 0.0 ## The time the Continuous change ends.
	var end_step_time:float = 0.0 ## The time in steps the Continuous change ends.
	
	func _init(new_bpm:float = 100.0, time:float = 0):
		self.bpm = new_bpm
		self.song_time = time
	
	## Maps this current [member BpmChange] based off of a [member BpmChange].[br]
	## It should be the previous [member BpmChange] but you can map it based off of any really.
	func map(prev:BpmChange) -> BpmChange:
		
		# TODO: modify `step_time` setting if the BpmChange is continuous
		
		self.step_time = prev.step_time + (self.song_time - prev.song_time) / Conductor._get_step_crochet_ms(prev.bpm)
		self.beat_time = prev.beat_time + (self.step_time - prev.step_time) / prev.steps_per_beat
		self.measure_time = prev.measure_time + (self.beat_time - prev.beat_time) / prev.beats_per_measure
		
		return self

var bpm_changes:Array[BpmChange] = [BpmChange.dummy]
var bpm_change_index:int = 0:
	set(v): bpm_change_index = clampi(v, 0, bpm_changes.size())
var current_bpm_change:BpmChange:
	get: return get_bpm_change(bpm_change_index)

func get_bpm_change(idx:int) -> BpmChange: return BpmChange.dummy if bpm_changes.size() <= 0 else bpm_changes[idx]

func map_new_bpm_at_time(new_bpm:float, song_time:float) -> BpmChange:
	# The idea is since we map a new bpm change, we want to use the bpm change before the last one so we can remap properly
	# An issue is if we just reference the last bpm change in the array, we assume that new maps are always *after* the last index, which is bad.
	#
	# Now I want to fix this so it will filter out all the items in the [bpm_changes] and find the last bpm change based off where we slot this in, and insert at the index
	# But im lazy rn so add this to the TODO :)
	var change:BpmChange = BpmChange.new(new_bpm, song_time).map(current_bpm_change)
	
	bpm_changes.push_back(change)
	return change
#endregion

#region Signals
signal on_step_hit(step:int) ## Emitted when the [member cur_step] changes
signal on_beat_hit(beat:int) ## Emitted when the [member cur_beat] changes
signal on_measure_hit(measure:int) ## Emitted when the [member cur_measure] changes

signal on_bpm_change(new_bpm:float) ## Emitted when the [member bpm] changes
signal on_time_signature_change(beats_measure:int, steps_measure:int) ## Emitted when we have changed Time Signatures

signal on_start() ## Emitted when we start the audio for the [Conductor]
signal on_pause() ## Emitted when we pause the audio for the [Conductor]
signal on_resume() ## Emitted when we resume the audio for the [Conductor]
signal on_conductor_finished() ## Emitted when the audio finishes for the [Conductor]
#endregion

#region Magic Time Signature Formula Calculations and Variables
var beats_per_measure:int: ## Number of beats per measure[br](beats_per_measure / steps_per_beat)
	get: return BpmChange.dummy.beats_per_measure if bpm_changes.size() <= 0 else current_bpm_change.beats_per_measure
var steps_per_beat:int: ## Number of step per beat[br](beats_per_measure / steps_per_beat)
	get: return BpmChange.dummy.steps_per_beat if bpm_changes.size() <= 0 else current_bpm_change.steps_per_beat

var bpm:float:
	get: return BpmChange.dummy.bpm if bpm_changes.size() <= 0 else current_bpm_change.bpm
	set(v): BpmChange.dummy.bpm = abs(v) # This is only here so we can modify the dummy in case you modify bpm directly ig


var cur_step_float:float = 0 ## Current Step as a [float]. See [member cur_step] for the [int] value
var cur_step:int: ## Current Step as a [int]. See [member cur_step_float] for the [float] value
	get: return floor(cur_step_float)

var cur_beat_float:float = 0 ## Current Beat as a [float]. See [member cur_beat] for the [int] value
var cur_beat:int: ## Current Beat as a [int]. See [member cur_beat_float] for the [float] value
	get: return floor(cur_beat_float)

var cur_measure_float:float = 0 ## Current Measure as a [float]. See [member cur_measure] for the [int] value
var cur_measure:int: ## Current Measure as a [int]. See [member cur_measure_float] for the [float] value
	get: return floor(cur_measure_float)

var step_crotchet:float: ## Time per step, in milliseconds
	get: return _get_step_crochet_ms(bpm)
## So we can reuse the ms calculation for any BPM if needed.
func _get_step_crochet_ms(_bpm:float) -> float: return (15000 / _bpm)

var crotchet:float: ## Time per beat, in milliseconds
	get: return _get_crochet_ms(bpm)
## So we can reuse the ms calculation for any BPM if needed.
func _get_crochet_ms(_bpm:float) -> float: return (15000 * steps_per_beat) / _bpm

#endregion

#region Audio Bus / Playback Position
## [AudioStream] that will be played by [member _audio_player][br]
## If Audio has a BPM attached to it, it will update [member bpm] automatically
var audio_stream:AudioStream:
	get: return _audio_player.stream
	set(v):
		_audio_player.stream = v
		if _audio_player.stream.bpm <= 0: return
		bpm = _audio_player.stream.bpm

var audio_bus:StringName:## [AudioStream]'s Audio Bus.
	get: return _audio_player.bus
	set(v): _audio_player.bus = v

var _audio_player:AudioStreamPlayer = AudioStreamPlayer.new()

var offset:float = 0## Offset in milliseconds

var _latency:float = AudioServer.get_output_latency()## [AudioServer] latency cache

## Current position in milliseconds.
var song_position:float:
	get: return (playback_position*1000) - offset

## Used for checking actual position, [member song_position] is used for exact current time with an offset.
var playback_position:float:
	get: return (_audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()) - _latency
	set(v): _audio_player.seek(v) # Really you shouldn't be able to set it, but what the heck lol

## Returns the current length of the [AudioStream], in Seconds.
var length:float:
	get: return _audio_player.stream.get_length()

## A 0 - 1 range, 0 being the start, and 1 being finished.[br]
## Is not based off of [member song_position], but rather the internal position.
var percent:float:
	get: return (playback_position / length)
#endregion

func _init() -> void:
	audio_bus = &"Music"
	_audio_player.finished.connect(finished)
	add_child(_audio_player)

func _process(_delta: float) -> void:
	if paused or !has_started: return # Nao need to calculate if we aren't progressing lol
	
	var old_step:int = cur_step
	var old_beat:int = cur_beat
	var old_measure:int = cur_measure
	
	var old_bpm_change_index:int = bpm_change_index
	
	bpm_change_index = bpm_change_from_time(song_position, bpm_change_index)
	
	cur_step_float = steps_from_time(song_position, bpm_change_index, bpm_from_time(song_position, bpm_change_index))
	cur_beat_float = current_bpm_change.beat_time + (cur_step_float - current_bpm_change.step_time) / steps_per_beat
	cur_measure_float = current_bpm_change.measure_time + (cur_beat_float - current_bpm_change.beat_time) / beats_per_measure
	
	if bpm_change_index != old_bpm_change_index:
		var prev_change:BpmChange = get_bpm_change(old_bpm_change_index)
		if (beats_per_measure != prev_change.beats_per_measure || steps_per_beat != prev_change.steps_per_beat):
			on_time_signature_change.emit(beats_per_measure, steps_per_beat)
		
		if (current_bpm_change.bpm != prev_change.bpm):
			on_bpm_change.emit(current_bpm_change.bpm)
	
	if old_step != cur_step:
		for i in range(old_step, cur_step): on_step_hit.emit(i+1)
		if cur_step % steps_per_beat == 0: for i in range(old_beat, cur_beat): on_beat_hit.emit(i+1)
		if cur_beat % beats_per_measure == 0: for i in range(old_measure, cur_measure): on_measure_hit.emit(i+1)

#region Conductor Utility Functions for handling current steps, and converting between steps and song time
func bpm_change_from_time(time:float, idx:int = 0) -> int:
	var _len:int = bpm_changes.size()
	if _len < 2: return (_len - 1)
	
	idx = clampi(idx, 0, _len)
	if get_bpm_change(idx).song_time > time:
		while (idx > 0):
			if time > get_bpm_change(idx).song_time: return idx
			else: idx -= 1
		return 0
	
	for i in range(idx, _len): if get_bpm_change(i).song_time > time: return (idx - 1)
	return (_len - 1)

func bpm_from_time(_time:float, idx:int = 0) -> float:
	var change:BpmChange = get_bpm_change(idx)
	# This is where we would implement continuous BPM Changes for this ig
	
	return change.bpm

func steps_from_time(time:float, idx:int, _bpm:float) -> float:
	var change:BpmChange = get_bpm_change(idx)
	# Another instance for future continuous BPM Changes implementation
	
	return change.step_time + (time - change.song_time) / _get_step_crochet_ms(_bpm)
#endregion

var paused:bool:##Setting this directly will pause or resume the audio. You can also call [member pause()] / [member resume()] if you really want to.
	get: return _audio_player.stream_paused
	set(v):
		if (v): on_pause.emit()
		else: on_resume.emit()
		_audio_player.stream_paused = v

var has_started:bool:## Just returns a [bool] if our position is above 0
	get: return playback_position > 0

func play() -> void:## Starts playing the audio for the conductor
	_audio_player.play()
	on_start.emit()

func stop() -> void:
	_audio_player.stop()## Stops the audio from playing.

func finished() -> void:
	stop()
	bpm_changes = [BpmChange.dummy]
	on_conductor_finished.emit()## When the audio is [finished] playeing
