class_name ChartMeta extends Resource

@export var name:String
@export var display_name:String

@export var bpm:float = 100 ## You can assign a BPM in the Meta, or use the Inst.ogg to assign the BPM!
@export var beats_per_measure:int = 4
@export var steps_per_beat:int = 4

@export var difficulties:Array[String] = ["easy", "normal", "hard"]

@export var require_voices:bool = false
@export var inst_suffix:String = ""
@export var vocal_suffix:String = ""

@export var extra:Dictionary = {}

static func from_cne_chart(data:Dictionary) -> ChartMeta:
	var meta:ChartMeta = ChartMeta.new()
	
	if data.name: meta.name = data.name
	if data.displayName: meta.display_name = data.displayName
	
	if data.bpm: meta.bpm = data.bpm
	if data.beatsPerMeasure: meta.beats_per_measure = data.beatsPerMeasure
	if data.stepsPerBeat: meta.steps_per_beat = data.stepsPerBeat
	
	if data.difficulties: meta.difficulties = data.difficulties
	
	if data.vocalsSuffix: meta.vocal_suffix = data.vocalsSuffix
	if data.instSuffix: meta.inst_suffix = data.instSuffix
	if data.needsVoices: meta.require_voices = data.needsVoices
	
	if data.customValues: meta.extra = (data.customValues as Dictionary)
	return meta
