class_name ChartStrumLine extends Resource

@export var scroll_speed:float = 1
@export var scale:float = 1
@export var spacing_mult:float = 1
@export var vocals_suffix:String = ""
@export var notes:Array[ChartNote] = []
@export var key_count:int = 4

@export var visible:bool = true
@export var transparency:float = 1

static func from_cne_chart(json:Dictionary, data:Dictionary) -> ChartStrumLine:
	var strumline:ChartStrumLine = ChartStrumLine.new()
	
	strumline.key_count = data.get('keyCount', strumline.key_count)
	strumline.vocals_suffix = data.get('vocalsSuffix', strumline.vocals_suffix)
	strumline.scroll_speed = data.get('scrollSpeed', json.get('scrollSpeed', strumline.scroll_speed))
	strumline.scale = data.get('strumScale', strumline.scale)
	# TODO: add `data.position` here cuz im lazy :)
	for data_note in data.get('notes', []): strumline.notes.push_back(ChartNote.from_cne_chart(json, data_note))
	ChartStrumLine.sort_notes(strumline.notes)
	return strumline

static func sort_notes(_notes:Array[ChartNote]): _notes.sort_custom((func(a:ChartNote, b:ChartNote): return a.time < b.time))

func filter_direction(dir:FunkinHelper.DirectionType) -> Array[ChartNote]:
	return notes.filter(func(note:ChartNote): return note.direction == dir)
