@tool
## A single Strum that builds a StrumLine. Contains all the Notes that you press on this Strum
class_name Strum extends Node2D

signal onInput(direction:NoteDirection, input:InputType) ## Emits a signal for various Key Inputs

@onready var sprite:AnimatedSprite2D = $Sprite ## The "Strum"'s Sprite itself.
@onready var notesGroup:Node2D = $Notes ## A Node2D containing all the notes in the song. Better than an array!

## The MS render distance to update a note. 1500 is usually off screen but adjust if the window height or zoom makes notes appear randomly
var render_limit:float = 1500

#region Strum Values

var strumLine:StrumLine ## This Strum's bounded StrumLine

var scrollSpeed:float = 1.5: ## Your Single Strum's speed for how fast notes arrive at the strum.
	set(value): scrollSpeed = abs(value)

@export var direction:NoteDirection = NoteDirection.LEFT: ## Your strum's Direction.
	set(value):
		if value is int:
			match value % 4:
				1: value = NoteDirection.DOWN;
				2: value = NoteDirection.UP;
				3: value = NoteDirection.RIGHT;
				_: value = NoteDirection.LEFT;
		direction = value
		init()

var hitNote:bool = false ## When you are actively hitting a note. Somewhat of an Internal Variable

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


func init()->void: ## Initalizes the strum 
	if !sprite: return
	sprite.play("%s%s" % [direction_to_string(direction), _static])

const INPUT_NAME = &"NOTE_%s" ## For inputs, using the Keybind names
## Converts Enum to string value.
static func direction_to_string(dir:NoteDirection = NoteDirection.LEFT)->String: return NoteDirection.keys()[dir].to_lower()

# Handling how notes are added and removed from the Strum
const note_blueprint := preload("res://Funkin/Game/Note.tscn") ## The Note Scene that is used to dynamically create notes
func spawn_note(time:float, sustainLength:float)->void:
	var note = note_blueprint.instantiate()
	notesGroup.add_child(note)
	note.init(self, time, sustainLength)

func loop_for_notes(fiction:Callable) -> void: ## Simple utility function to quickly loop through all the notes
	for i:Note in notesGroup.get_children():
		if !i is Note: continue
		fiction.call(i)

func _process(_delta: float) -> void:
	loop_for_notes(func(note:Note):
		if note.render or (note.strumTime - Conductor.song_position) >= render_limit: return
		note.render = true
		note.visible = true
	)

## Input Handler
func on_input()->void:
	if Engine.is_editor_hint(): return
	var dir = direction_to_string(direction)
	var action = INPUT_NAME % dir
	
	if Input.is_action_just_pressed(action):
		onInput.emit(direction, InputType.JustPressed)
	
	if Input.is_action_pressed(action):
		process_pressed()
	
	if Input.is_action_just_released(action):
		sprite.play("%s%s" % [dir, _static])
		hitNote = false
		onInput.emit(direction, InputType.JustReleased)

func process_pressed()->void: ## When your activly pressing down on a key. Internal Function
	var anim = "%s%s" % [direction_to_string(direction), (confirm if hitNote else press)]
	
	if sprite.animation != anim: sprite.play(anim)
	
	onInput.emit(direction, InputType.Press)
	
	loop_for_notes(func(note:Note): if note.canBeHit and !note.wasGoodHit: note.goodNoteHit() )
	
	# New idea. Filter out notes directly instead of looping through them all at once.
	# Then just loop through the filter
	
	# Idea was good, it sucks though since it can sometimes just ghost kill notes
	#var notes = notesGroup.get_children()
	#notes = notes.filter(func(note): return (note.canBeHit and !note.wasGoodHit))
	#for note:Note in notes: note.goodNoteHit()
