@tool
## A single Strum that builds a StrumLine. Contains all the Notes that you press on this Strum
class_name Strum extends Node2D

signal onInput(direction:NoteDirection, input:InputType) ## Emits a signal for various Key Inputs

@onready var sprite:AnimatedSprite2D = $Sprite ## The "Strum"'s Sprite itself.
@onready var notesGroup:Node2D = $Notes ## A Node2D containing all the notes in the song. Better than an array!

var strum_path:String = "res://Assets/Images/Notes/%s/static.tres"

## The MS render distance to update a note. 1500 is usually off screen but adjust if the window height or zoom makes notes appear randomly
var render_limit:float = 1500

var earlyPressWindow:float = 0.5 ## Placeholder Information. I have no clue what this does
var latePressWindow:float = 1 ## Placeholder Information. I have no clue what this does
var hitWindow:float = 160 ## Time im MS of the window you have to hit the note

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
	set_physics_process(false)

func init()->void: ## Initalizes the strum 
	if !sprite: return
	sprite.sprite_frames = load(strum_path % "default")
	sprite.play("%s%s" % [direction_to_string(direction), _static])

const INPUT_NAME = &"NOTE_%s" ## For inputs, using the Keybind names
## Converts Enum to string value.
static func direction_to_string(dir:NoteDirection = NoteDirection.LEFT)->String: return NoteDirection.keys()[dir].to_lower()

## Packed information of time and susLength. The game will assume the PackedArray is sorted from lowest to highest
var notes_to_spawn:PackedFloat32Array = PackedFloat32Array()
func preload_note(t:float, l:float) -> void:
	notes_to_spawn.push_back(t)
	notes_to_spawn.push_back(l)

func sort_preload_notes():
	var count = notes_to_spawn.size() * 0.5
	var pairs:Array = []
	
	for i in range(count):
		var t = notes_to_spawn[i * 2]
		var l = notes_to_spawn[i * 2 + 1]
		pairs.append({ "t": t, "l": l })  # Could also be a custom class
	
	pairs.sort_custom(func(a, b): return a["t"] < b["t"])

	# Rebuild the PackedFloat32Array
	var sorted_flat:PackedFloat32Array = PackedFloat32Array()
	for p in pairs:
		sorted_flat.push_back(p["t"])
		sorted_flat.push_back(p["l"])
	
	notes_to_spawn = sorted_flat

# Handling how notes are added and removed from the Strum
const note_blueprint:PackedScene = preload("res://Funkin/Game/Note.tscn") ## The Note Scene that is used to dynamically create notes
func spawn_note(time:float, sustainLength:float)->Note: ## Physically Spawns the note in the Notes Node2D. Returns the newly created instance
	var note = note_blueprint.instantiate()
	notesGroup.add_child(note)
	note.init(self, time, sustainLength)
	return note

func loop_for_notes(fiction:Callable) -> void: ## Simple utility function to quickly loop through all the notes
	for i:Note in notesGroup.get_children():
		if !i is Note: continue
		fiction.call(i)

# da rendoring toime!
func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()): return
	
	if notes_to_spawn.size() >= 2:
		var t = notes_to_spawn[0] # Look at our current buffer
		var l = notes_to_spawn[1] # Look ahead for susLength
		if (t - Conductor.song_position) <= render_limit: # check if note should be rendered
			spawn_note(t, l).render = true
			notes_to_spawn.remove_at(0) # remove t
			notes_to_spawn.remove_at(0) # remove l (same index again)

func _input(event:InputEvent):
	if !strumLine.isPlayer or Engine.is_editor_hint(): return
	
	if event is not InputEventKey: return
	
	var dir = direction_to_string(direction)
	var action = INPUT_NAME % dir
	
	if Input.is_action_just_pressed(action):
		check_note_press()
		
		onInput.emit(direction, InputType.JustPressed)
	
	if event.is_action_pressed(action):
		var anim = "%s%s" % [direction_to_string(direction), (confirm if hitNote else press)]
		if sprite.animation != anim: sprite.play(anim)
		
		onInput.emit(direction, InputType.Press)
	
	if event.is_action_released(action):
		sprite.play("%s%s" % [dir, _static])
		hitNote = false
		
		loop_for_notes(func(note:Note):
			if note.failedHit or (!note.canBeHit and !note.wasGoodHit): return
			note.failedHit = true
		)
		
		onInput.emit(direction, InputType.JustReleased)

func check_note_press()->void:
	var sorted_notes := notesGroup.get_children().filter(func(note:Note): return (note is Note) and (note.canBeHit and !note.wasGoodHit))
	
	if sorted_notes.is_empty(): return
	
	sorted_notes.sort_custom(func(a:Note, b:Note): return a.strumTime < b.strumTime)
	sorted_notes[0].goodNoteHit()
