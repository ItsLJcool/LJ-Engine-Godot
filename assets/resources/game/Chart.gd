class_name Chart extends Resource

@export var stage:String = "stage"
@export var scroll_speed:float = 1
@export var strumlines:Array[ChartStrumLine] = []

@export var meta:ChartMeta = ChartMeta.new()

static var songs_path:StringName = &"assets/songs"
static var charts_path:StringName = &"charts"

static func get_chart_json(song_name:String, difficulty:String = "normal") -> String: return "%s/%s/%s/%s.json" % [songs_path, song_name, charts_path, difficulty]
static func get_meta_json(song_name:String) -> String: return "%s/%s/meta.json" % [songs_path, song_name]

func get_vocals() -> Array[String]:
	var vocals:Array[String] = []
	for strumline in strumlines:
		if strumline.vocals_suffix.strip_edges() == "": continue
		vocals.push_back(strumline.vocals_suffix)
	if vocals.is_empty(): return [""]
	return vocals

## Quick utility to parse a json
static func parse_json(path:String)->Dictionary:
	if (!FileAccess.file_exists(path)):
		push_warning("Path doesn't exist: ", path)
		return {}
	
	var json_str = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(json_str.get_as_text())
	if (!json is Dictionary):
		print("Error reading file")
		return {}
	
	return json

## Converts a CodenameEngine chart so we can read it in Godot.[br]NOTE: it doesn't parse Events yet.
static func from_cne_chart(song_name:String, difficulty:String = "normal") -> Chart:
	var json = parse_json(get_chart_json(song_name, difficulty))
	var meta_path:String = get_meta_json(song_name)
	
	var chart:Chart = Chart.new()
	chart.stage = json.get('stage', 'stage')
	
	if FileAccess.file_exists(meta_path): chart.meta = ChartMeta.from_cne_chart(parse_json(meta_path))
	
	for data in json.get('strumLines', []): chart.strumlines.push_back(ChartStrumLine.from_cne_chart(json, data))
	
	return chart
