class_name Strum extends AnimatedSprite2D

## The Strum's Type as a String
var strum_type:StringName = &"default":
	set(v):
		strum_type = v
		reload_note_animations()
var remap_type:FunkinHelper.FunkinAnimationRemap:
	get: return FunkinHelper.get_remap(self.strum_type)

var dir:FunkinHelper.DirectionType = FunkinHelper.DirectionType.LEFT
var direction_name:StringName:
	get: return FunkinHelper.direction_to_nametype(dir, strum_type)

var render_limit:float = 1500

var notes_group:Node2D = Node2D.new()
## Returns an array of [Note], but can contain [Node] if casting fails ig?
var notes:Array[Node]:
	get: return notes_group.get_children().filter(func(note:Node): return (note is Note))

var chart_notes:Array[ChartNote] = []
var _first_note:ChartNote:
	get: return chart_notes[0] if !chart_notes.is_empty() else null

func preload_notes(_notes:Array[ChartNote]) -> void:
	chart_notes.append_array(_notes)
	ChartStrumLine.sort_notes(chart_notes)

func spawn_note(data:ChartNote):
	var note:Note = Note.new(data.time, data.sus_length, data.direction, data.type)
	note.binding_strum = self
	notes_group.add_child(note)

## The SparrowAtlas referencing for the xml / texture that will automatically be parsed :)
var sparrow_atlas:SparrowAtlas:
	set(v):
		sparrow_atlas = v
		sprite_frames = v.sprite_frames
		return v

var early_press_window:float = 0.5
var late_press_window:float = 1
var hit_window:float = 160

var scroll_speed:float = 1

## Temporary variable
var cpu:bool = true

func reload_note_animations() -> void:
	sparrow_atlas = SparrowAtlas.new(Note.NOTE_PATH % strum_type)
	
	play("%s-%s" % [remap_type.ARROW, direction_name])

func _init(_dir:FunkinHelper.DirectionType = FunkinHelper.DirectionType.LEFT, type:StringName = "") -> void:
	
	dir = _dir
	strum_type = type
	
	reload_note_animations()
	
	add_child(notes_group)

const _INPUT_NAME:StringName = &"NOTE_%s"## Internal name for the Input for the strum being pressed
var _cur_action:StringName:
	get: return _INPUT_NAME % direction_name.to_upper()

# TODO: have input for StrumLine and not each Strum :)
func _input(event:InputEvent):
	if (cpu or event is not InputEventKey or Engine.is_editor_hint()): return
	
	var did_press:bool = false
	if Input.is_action_just_pressed(_cur_action):
		did_press = check_note_press()
	
	if event.is_action_pressed(_cur_action):
		var anim:String = "%s %s" % [direction_name,remap_type.CONFIRM if did_press else remap_type.PRESS]
		if animation != anim: play(anim)
	
	if event.is_action_released(_cur_action):
		play("%s-%s" % [remap_type.ARROW, direction_name])
		notes.filter(func(note:Note):
			if (note.can_be_hit and note.was_good_hit):
				note.failed_hit = true
				return true
			return false
		)

func check_note_press()->bool:
	var sorted_notes:Array[Node] = notes.filter(func(note:Note):
		return (note.can_be_hit and !note.was_good_hit and !note.failed_hit)
	)
	
	if sorted_notes.is_empty(): return false
	sorted_notes.pop_front().on_hit()
	
	return true


func _process(_delta: float) -> void:
	
	if _first_note and (_first_note.time - Conductor.song_position) <= render_limit:
		spawn_note(chart_notes.pop_front())
