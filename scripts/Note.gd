class_name Note extends AnimatedSprite2D

signal on_hit

var clip_rect:Control = Control.new()
var sustain:TextureRect = TextureRect.new()
var end:Sprite2D = Sprite2D.new()

# cache of the end (tail)'s texture size
var _end_size:Vector2 = Vector2.ONE

static var NOTE_PATH:StringName = &"res://assets/game/notes/%s"

## The SparrowAtlas referencing for the xml / texture that will automatically be parsed :)
var sparrow_atlas:SparrowAtlas:
	set(v):
		sparrow_atlas = v
		sprite_frames = v.sprite_frames
		return v

## The Note Type as a string
var note_type:StringName = &"default"
var remap_type:FunkinHelper.NoteAnimationRemap:
	get: return FunkinHelper.NoteAnimationRemap.get_remap(self.note_type)

var dir:FunkinHelper.DirectionType = FunkinHelper.DirectionType.LEFT:
	set(v):
		dir = v
		reload_note_animations()
var direction_name:StringName:
	get: return FunkinHelper.NoteAnimationRemap.direction_to_nametype(dir, note_type)

## If true, Hold Pieces will use the 1st pixel row of the Tail texture, otherwise uses normal hold piece texture
var use_sustain_texture:bool = true

var use_local_scroll_speed:bool = false
var scroll_speed:float = 1:
	get:
		if binding_strum and not use_local_scroll_speed: return binding_strum.scroll_speed
		return scroll_speed

@warning_ignore("unused_private_class_variable")
var _scroll_length:float:
	get: return (0.6 * (scroll_speed * 100) / 100)

var time:float = 1500: ## The time in milliseconds when the note should be hit
	set(v): time = abs(v)

var is_sustain_note:bool = false: ## If the note should have a sustain and end tail.
	set(v):
		is_sustain_note = v
		if !sustain or !end: return
		sustain.visible = v
		end.visible = v

var sus_length:float = 0:
	set(v):
		sus_length = abs(v)
		is_sustain_note = (sus_length > 0.0)
		if !sustain or !end: return
		_set_sus_displacement(v)

func _set_sus_displacement(v:float) -> void:
	var is_flipped:bool = (v < 0.0)
	end.position.y = abs(v) - _end_size.y
	end.offset.y = -0.001 # for any floating point rounding errors :)
	
	sustain.size = Vector2(_end_size.x, end.position.y)
	sustain.position = Vector2.ZERO
	
	clip_rect.rotation_degrees = 0 if !is_flipped else 180
	clip_rect.size = sustain.size; clip_rect.size.y += _end_size.y
	clip_rect.position.x = -clip_rect.size.x * 0.5 if !is_flipped else clip_rect.size.x * 0.5

func _init(strum_time:float = 1500, sus:float = 0, _dir:FunkinHelper.DirectionType = FunkinHelper.DirectionType.LEFT, type:StringName = &"default"):
	set_physics_process(false)
	set_process_input(false)
	visible = false
	
	note_type = type
	dir = _dir
	
	self.z_index = 1
	clip_rect.z_index = -1
	
	clip_rect.clip_contents = true
	sustain.clip_contents = true
	end.centered = false
	
	add_child(clip_rect)
	clip_rect.add_child(sustain)
	clip_rect.add_child(end)
	
	sus_length = sus
	clip_rect.modulate.a = 0.7
	
	self.time = strum_time

func reload_note_animations() -> void:
	sparrow_atlas = SparrowAtlas._load(NOTE_PATH % note_type)
	
	play(direction_name)
	
	if !use_sustain_texture:
		var tex := AtlasTexture.new();
		tex.filter_clip = true
		tex.atlas = sprite_frames.get_frame_texture("%s %s" % [direction_name, remap_type.END], 0)
		tex.region.size.y = 1
		sustain.texture = tex
		sustain.stretch_mode = TextureRect.STRETCH_SCALE
	else:
		sustain.texture = sprite_frames.get_frame_texture("%s %s" % [direction_name, remap_type.HOLD], 0)
		sustain.stretch_mode = TextureRect.STRETCH_TILE
	
	sustain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	var end_tex := AtlasTexture.new()
	end_tex.filter_clip = true
	end_tex.atlas = sprite_frames.get_frame_texture("%s %s" % [direction_name, remap_type.END], 0)
	end.texture = end_tex
	
	_end_size = end.texture.get_size()

func delete() -> void:
	queue_free()

var can_be_hit:bool = false
var too_late:bool = false
var avoid:bool = false
var was_good_hit:bool = false

var failed_hit:bool = false:
	set(v):
		failed_hit = v
		if v: was_good_hit = false
		if !is_sustain_note: return
		self_modulate.a = 1
		modulate.a = 0.5
		z_index = -2

var binding_strum:Strum = null

func hit() -> void:
	if failed_hit: return
	was_good_hit = true
	
	on_hit.emit()
	
	if is_sustain_note: self_modulate.a = 0
	else: delete()

func _process(_delta:float):
	self.position.y = NotePositionRemap.normal(time, _scroll_length)
	
	if not binding_strum: return
	visible = true
	
	can_be_hit = (
		(time + sus_length) > Conductor.song_position - (binding_strum.hit_window * binding_strum.late_press_window)
		and time < Conductor.song_position + (binding_strum.hit_window * binding_strum.early_press_window)
	)
	
	if (binding_strum.cpu and !avoid and !was_good_hit && time < Conductor.song_position):
		hit()
	
	if ((time + sus_length) < (Conductor.song_position - binding_strum.hit_window) and !was_good_hit):
		too_late = true
		delete()
	
	if (was_good_hit and (time + sus_length) < Conductor.song_position):
		delete()
		return
	
	if is_sustain_note: _update_sustain()


func _update_sustain() -> void:
	if was_good_hit:
		_set_sus_displacement(((sus_length + time) - Conductor.song_position) * _scroll_length)
		global_position = binding_strum.global_position
	else: _set_sus_displacement(sus_length * _scroll_length)
