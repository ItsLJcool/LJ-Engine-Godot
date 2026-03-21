class_name ChartMeta extends Resource

@export var name:String
@export var display_name:String

@export var bpm:float = 100 ## You can assign a BPM in the Meta, or use the Inst.ogg to assign the BPM!
@export var beats_per_measure:int = 4
@export var steps_per_beat:int = 4

@export var difficulties:Array = ["easy", "normal", "hard"]

@export var require_voices:bool = false
@export var inst_suffix:String = ""
@export var vocal_suffix:String = ""

@export var extra:Dictionary = {}

static func from_cne_chart(data:Dictionary) -> ChartMeta:
	var meta:ChartMeta = ChartMeta.new()
	
	meta.name = data.get("name", meta.name)
	meta.display_name = data.get("displayName", meta.display_name)
	
	meta.bpm = data.get("bpm", meta.bpm)
	meta.beats_per_measure = data.get("beatsPerMeasure", meta.beats_per_measure)
	meta.steps_per_beat = data.get("stepsPerBeat", meta.steps_per_beat)
	
	meta.difficulties = data.get("difficulties", meta.difficulties) as Array[String] # doesn't work fsr so kms
	
	meta.vocal_suffix = data.get("vocalsSuffix", meta.vocal_suffix)
	meta.inst_suffix = data.get("instSuffix", meta.inst_suffix)
	meta.require_voices = data.get("needsVoices", meta.require_voices)
	
	if data.has("customValues"): meta.extra = (data.customValues as Dictionary)
	return meta
