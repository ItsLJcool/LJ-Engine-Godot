class_name Note extends Node2D

#region Initalize Variable Names
@onready var sprite:AnimatedSprite2D = $Sprite
@onready var sustain:Line2D = $Sustain
@onready var clipRect:Control = $Sustain/ClipRect
@onready var end:Sprite2D = $Sustain/ClipRect/End

var sustainsPath:String = "res://Assets/Notes/%s/sustains/%s-sustain.png"
var endPath:String = "res://Assets/Notes/%s/sustains/%s-end.png"

## The Note's bounded Strum
var strum:Strum

#endregion

#region Note Information

## If things like updating the note should occur. Internal variable used by Strum.gd
var render:bool = false

var isSustainNote:bool = true

var susLength:float = 200:
	set(value):
		if susLength <= 0.0: isSustainNote = false
		susLength = abs(value)
		if sustain and end:
			sustain.set_point_position(sustain.get_point_count()-1, Vector2(0, value))
			end.flip_v = true if value < 0 else false
			end.flip_h = end.flip_v
			end.position = sustain.position
			end.position.y += value

var strumTime:float = 3000

var earlyPressWindow:float = 0.5
var latePressWindow:float = 1

var canBeHit:bool = false
var tooLate:bool = false
var wasGoodHit:bool = false

## Honestly I have no fucking clue what this does beside increase the- oh wait right its in the name
var hitWindow:float = 160;

## If you should NOT hit the note and avoid it.
var avoid:bool = false;
#endregion

func init(_strum:Strum, time:float, sustainLength:float)->void:
	self.visible = false
	
	strum = _strum
	strumTime = time
	susLength = sustainLength
	
	if (sprite.sprite_frames.get_meta("use_rotation")):
		match strum.direction:
			Strum.NoteDirection.DOWN, Strum.NoteDirection.UP:
				sprite.rotation_degrees = -90
	
	var dirName:String = Strum.direction_to_string(strum.direction)
	sprite.play(dirName)
	sustain.texture = load(sustainsPath % ["default", dirName])
	end.texture = load(endPath % ["default", dirName])

func _ready():
	if (!Engine.is_editor_hint()): clipRect.clip_contents = true;
	self.position.y = -5000
	
func deleteNote():
	self.queue_free()

func goodNoteHit():
	wasGoodHit = true
	strum.hitNote = true
	
	#var noteDiff = abs(Conductor.song_position - strumTime);
	#var daRating:String = "sick";
	#var score:int = 300;
	#var accuracy:float = 1;
	
	if !isSustainNote: deleteNote()
	else: sprite.self_modulate.a = 0

func _process(delta: float) -> void:
	if !render: return
	update_note()

func update_note():
	self.position.y = (strumTime - Conductor.song_position) * (0.45 * (int(strum.scrollSpeed * 100) / 100) )
	
	canBeHit = ((strumTime + susLength) > Conductor.song_position - (hitWindow * latePressWindow)
		and strumTime < Conductor.song_position + (hitWindow * earlyPressWindow))
	
	if ((strumTime + susLength) < (Conductor.song_position - hitWindow) and !wasGoodHit):
		tooLate = true

	if (!strum.strumLine.isPlayer && !avoid && !wasGoodHit && strumTime < Conductor.song_position):
		goodNoteHit()

	if (wasGoodHit && (strumTime + susLength) < Conductor.song_position):
		deleteNote()
		return
	
	if (tooLate):
		deleteNote()
		return
	
	updateSustain()


func updateSustain():
	var lastPoint = sustain.get_point_position(sustain.get_point_count()-1)
	var _endSize = end.texture
	
	var lengthPog = (0.45 * round(strum.scrollSpeed * 100) / 100);
	var yVal = 0;
	if wasGoodHit:
		yVal = ((susLength + (strumTime - Conductor.song_position)) * lengthPog);
		
		sustain.position.y = -(position.y - strum.position.y);
	else:
		yVal = (susLength * lengthPog);
		
		sustain.position.y = 0;
	
	yVal -= _endSize.get_height();
	
	lastPoint.y = yVal;
	lastPoint.y = max(lastPoint.y, 0)
	
	sustain.set_point_position(sustain.get_point_count()-1, lastPoint);
	
	clipRect.position.x = -(_endSize.get_width() * 0.5);
	clipRect.size.x = _endSize.get_width();
	clipRect.size.y = yVal + _endSize.get_height();
	
	end.position.x = _endSize.get_width() * 0.5;
	end.position.y = yVal;
