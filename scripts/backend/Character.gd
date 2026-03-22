@tool
class_name Character extends AnimatedSprite2D


@export var animation_debug:String = "idle"
@warning_ignore("UNUSED_PRIVATE_CLASS_VARIABLE")
@export_tool_button("Play Debug Animation") var _debug_play = func(): play_anim(animation_debug, true)

static var PATH:StringName = &"res://assets/characters/%s"

@export_tool_button("Reload Character") var reload = func():
	update_sprite()
	update_ghost()
	pass


## The SparrowAtlas referencing for the xml / texture that will automatically be parsed :)
@export var sparrow_atlas:SparrowAtlas:
	set(v):
		sparrow_atlas = v
		sprite_frames = v.sprite_frames

@export var cur_character:String = "bf"

func update_sprite() -> void:
	sparrow_atlas = SparrowAtlas._load(PATH % cur_character)

var last_hit:float = -INF
var hold_time:float = 4.0

var suffix:String = ""
var allow_idle_suffix:bool = false

func attempt_dance():
	if Engine.is_editor_hint(): return
	if last_hit + (Conductor.step_crotchet * hold_time) < Conductor.song_position:
		dance()

func dance():
	play_anim("idle" if not allow_idle_suffix else "idle%s" % suffix)

func play_anim(_name:StringName, force:bool = false, reversed:bool = false) -> void:
	if force: stop()
	self.offset = sparrow_atlas.animation_offsets.get(_name, Vector2.ZERO)
	play(_name, 1, reversed)
	
	if not Engine.is_editor_hint(): last_hit = Conductor.song_position

func play_sing_anim(dir:FunkinHelper.DirectionType) -> void:
	var singDir:StringName = &"sing"
	match dir:
		FunkinHelper.DirectionType.DOWN: singDir += "DOWN"
		FunkinHelper.DirectionType.UP: singDir += "UP"
		FunkinHelper.DirectionType.RIGHT: singDir += "RIGHT"
		_: singDir += "LEFT"
	
	play_anim(singDir+suffix, true)

var ghost:GhostHandler = null
static var editor_ghost:bool = false

func _init(char_name:Variant = null):
	if char_name != null: cur_character = char_name
	if not Engine.is_editor_hint():
		Conductor.on_beat_hit.connect(beat_hit)
	elif not editor_ghost:
		editor_ghost = true
		update_ghost()
	editor_ghost = false

func update_ghost():
	if ghost != null: ghost.queue_free()
	ghost = GhostHandler.new(Character.new(cur_character))
	add_child(ghost)

func _ready() -> void:
	update_sprite()
	dance()

var dance_interval:int = 2

func beat_hit(beat:int):
	if beat < 0: return
	
	@warning_ignore("INTEGER_DIVISION")
	if beat % (dance_interval * maxi(floori(4 / Conductor.steps_per_beat), 1)) == 0: attempt_dance()
