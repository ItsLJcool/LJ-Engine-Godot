@tool
## A single Strum that builds a StrumLine. Contains all the Notes that you press on this Strum
class_name Strum extends Node2D

signal onInput(direction:NoteDirection, input:InputType)

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var notesGroup:Node2D = $Notes

var render_limit:float = 1500

#region Strum Values

var strumLine:StrumLine

var scrollSpeed:float = 1.5:
	set(value): scrollSpeed = abs(value)

@export var direction:NoteDirection = NoteDirection.LEFT:
	set(value):
		if value is int:
			match value % 4:
				1: value = NoteDirection.DOWN;
				2: value = NoteDirection.UP;
				3: value = NoteDirection.RIGHT;
				_: value = NoteDirection.LEFT;
		direction = value
		init()

## When you are actively hitting a note
var hitNote:bool = false

# these are for your custom direction names
var press = "-press" ## Animation suffix for your Sprite when pressing.
var confirm = "-confirm" ## Animation suffix for your Sprite when hitting a note.
var _static = "-static" ## Animation suffix for your Sprite when idle.

#endregion

#region enums
enum NoteDirection {
 	LEFT = 0,
 	DOWN = 1,
 	UP = 2,
	RIGHT = 3,
}

enum InputType {
	Press,
	Release,
	JustPressed,
	JustReleased
}
#endregion

func _ready():
	init()


func init()->void:
	if !sprite: return
	sprite.play("%s%s" % [direction_to_string(direction), _static])

var input_name = "NOTE_%s"
static func direction_to_string(dir:NoteDirection = NoteDirection.LEFT)->String: return NoteDirection.keys()[dir].to_lower()

# Handling how notes are added and removed from the Strum
const note_blueprint := preload("res://Funkin/Game/Note.tscn")
func spawn_note(time:float, sustainLength:float)->void:
	var note = note_blueprint.instantiate()
	notesGroup.add_child(note)
	note.init(self, time, sustainLength)

func loop_for_notes(fiction:Callable) -> void:
	for i in notesGroup.get_children():
		if !i is Note: continue
		fiction.call(i)

func _process(delta: float) -> void:
	
	loop_for_notes(func(note:Note):
		if note.render or (note.strumTime - Conductor.song_position) >= render_limit: return
		note.render = true
		note.visible = true
	)

## Input Handler
func on_input():
	if Engine.is_editor_hint(): return
	var dir = direction_to_string(direction)
	var action = input_name % dir
	
	if Input.is_action_just_pressed(action):
		onInput.emit(direction, InputType.JustPressed)
	
	if Input.is_action_pressed(action):
		process_pressed()
	
	if Input.is_action_just_released(action):
		sprite.play("%s%s" % [dir, _static])
		hitNote = false
		onInput.emit(direction, InputType.JustReleased)

func process_pressed():
	var anim = "%s%s" % [direction_to_string(direction), (confirm if hitNote else press)]
	
	if sprite.animation != anim: sprite.play(anim)
	
	onInput.emit(direction, InputType.Press)
	
	# Idea to not loop through every possible note:
	# use the `hitNote` variable and since each `Note` will have the reference to the strum, just check in the note directly so there is no looping involved.
	# or just do a big loop for each note and update them once in the proccess 🤷‍♂️
	loop_for_notes(func(note):
		if note.canBeHit and !note.wasGoodHit: note.goodNoteHit()
	)
