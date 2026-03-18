class_name ChartNote extends Resource

@export var time:float = 0
@export var direction:FunkinHelper.DirectionType = FunkinHelper.DirectionType.LEFT
@export var sus_length:float = 0
@export var type:StringName = &"default"

static func from_cne_chart(json:Dictionary, data:Dictionary) -> ChartNote:
	var note:ChartNote = ChartNote.new()
	var note_types:Array = json.get('noteTypes', [])
	if note_types.size() <= 0: note_types = [&'default']
	note.time = data.get('time', 0)
	note.direction = data.get('id', 0)
	note.type = note_types[clamp(data.get('type', 0), 0, note_types.size()-1)]
	note.sus_length = data.get('sLen', 0)
	return note
