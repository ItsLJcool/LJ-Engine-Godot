class_name Chart extends Resource

@export var stage:String = "stage"
@export var scroll_speed:float = 1
@export var strumlines:Array[ChartStrumLine] = []

@export var meta:ChartMeta = ChartMeta.new()

func get_vocals() -> Array[String]:
	var vocals:Array[String] = []
	for strumline in strumlines:
		if strumline.vocals_suffix.strip_edges() == "": continue
		vocals.push_back(strumline.vocals_suffix)
	if vocals.is_empty(): return [""]
	return vocals

## Quick utility to parse a json from the folder structure
static func parse_json(song_name:String, difficulty:String = "normal")->Dictionary:
	var path = "assets/songs/%s/charts/%s.json" % [song_name, difficulty]
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
	var json = parse_json(song_name, difficulty)
	var chart:Chart = Chart.new()
	chart.stage = json.get('stage', 'stage')
	if json.has('meta'): chart.meta = ChartMeta.from_cne_chart(json.get('meta'))
	
	for data in json.get('strumLines', []): chart.strumlines.push_back(ChartStrumLine.from_cne_chart(json, data))
	
	return chart
