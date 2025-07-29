class_name Note extends Node2D

#region Initalize Variable Names

@onready var sprite:AnimatedSprite2D = $Sprite ## The "Note" Sprite Itself. Not the Root Class for independent rotations.

@onready var clipRect:Control = $Sustain/ClipRect ## Used for clipping the end Sprite2D when hitting the full sustain
@onready var sustain:Line2D = $Sustain ## Your Sustain. Instead of like 5 billion seperate images 🔥
@onready var end:Sprite2D = $Sustain/ClipRect/End ## The end tail piece


var notePath:String = "res://Assets/Images/Notes/%s/arrows.tres"
var sustainsPath:String = "res://Assets/Images/Notes/%s/sustains/%s-sustain.png" ## Path for your sustain Images. use %s for the direction name
var endPath:String = "res://Assets/Images/Notes/%s/sustains/%s-end.png" ## Path for your end Images. use %s for the direction name

var strum:Strum ## The Note's bounded Strum

#endregion

#region Note Information

## If things like updating the note should occur. Internal variable used by Strum.gd
var render:bool = false:
	set(value):
		render = value
		self.visible = value

var isSustainNote:bool = true ## If the note is considered to have a Sustain and a tail.

var susLength:float = 200: ## The length of the sustain.
	set(value):
		if value <= 0.0: isSustainNote = false
		susLength = abs(value)
		if sustain and end:
			sustain.visible = isSustainNote
			end.visible = isSustainNote
			
			sustain.set_point_position(sustain.get_point_count()-1, Vector2(0, value))
			end.position = sustain.position
			end.position.y += value

var strumTime:float = 3000: ## The time in MS when the note should be hit
	set(value): strumTime = abs(value)

var canBeHit:bool = false ## If the note can be hit when in range of the Static Strum
var tooLate:bool = false ## If the note was too late to be hit
var wasGoodHit:bool = false ## If the note was hit

var avoid:bool = false ## If true, hitting the note counts as a miss

var failedHit:bool = false:
	set(value):
		if !isSustainNote: return
		if (value):
			self.modulate.a = 0.5
			self.z_index = -1
		failedHit = value
#endregion

func init(_strum:Strum, time:float, sustainLength:float)->void: ## Initalizing the Note to be used
	self.visible = false
	
	strum = _strum
	strumTime = time
	susLength = sustainLength
	
	sprite.sprite_frames = load(notePath % "default")
	
	if (sprite.sprite_frames.get_meta("use_rotation")):
		match strum.direction:
			Strum.NoteDirection.DOWN, Strum.NoteDirection.UP: sprite.rotation_degrees -= 90
	
	var dirName:String = Strum.direction_to_string(strum.direction)
	sprite.play(dirName)
	sustain.texture = load(sustainsPath % ["default", dirName])
	end.texture = load(endPath % ["default", dirName])
	
	clipRect.size = Vector2.ONE * sustain.width

func _ready():
	clipRect.clip_contents = true
	self.position.y = -5000
	sustain.modulate.a = 0.6
	
func deleteNote(): ## Simply just destroys the note
	self.queue_free()

func goodNoteHit()->void: ## Called when you hit the note properly
	wasGoodHit = true
	strum.hitNote = true
	
	#var noteDiff = abs(Conductor.song_position - strumTime);
	#var daRating:String = "sick";
	#var score:int = 300;
	#var accuracy:float = 1;
	
	if !isSustainNote: deleteNote()
	else: sprite.self_modulate.a = 0

func _process(_delta: float) -> void:
	if !render: return
	update_note()
	
	if canBeHit and wasGoodHit and !tooLate: 
		strum.strumLine.play_character_sing(strum.direction)

# Ok reference to everyone here:
# Hitting a sustain like normal but releasing it early should cause it to never be hittable again.
# Thats how I want the engine to handle sustains.
func update_note()->void: ## Call this to update position progression, and if the note should be hittable
	var lengthPog:float = (0.6 * ((strum.scrollSpeed) * 100) / 100)
	self.position.y = (strumTime - Conductor.song_position) * lengthPog
	
	canBeHit = !failedHit and ((strumTime + susLength) > Conductor.song_position - (strum.hitWindow * strum.latePressWindow)
		and strumTime < Conductor.song_position + (strum.hitWindow * strum.earlyPressWindow))
	
	if ((strumTime + susLength) < (Conductor.song_position - strum.hitWindow) and !wasGoodHit):
		tooLate = true
	
	if (!strum.strumLine.isPlayer && !avoid && !wasGoodHit && strumTime < Conductor.song_position):
		goodNoteHit()
	
	if (wasGoodHit && (strumTime + susLength) < Conductor.song_position):
		deleteNote()
		return
	
	if (tooLate):
		deleteNote()
		return
	
	if isSustainNote: update_sustain(lengthPog)

# TODO: rewrite how sustains work :sob:
func update_sustain(lengthPog:float)->void: ## Updates the Length of the sustain when hitting or not hitting.
	var points_count:int = sustain.get_point_count()
	if points_count < 2: return
	
	var end_size:Vector2 = end.texture.get_size()
	
	var y_val:float = 0;
	if wasGoodHit:
		y_val = ((susLength + (strumTime - Conductor.song_position)) * lengthPog);
		sustain.global_position.y = strum.global_position.y
	else:
		y_val = (susLength * lengthPog);
		sustain.global_position.y = global_position.y
	
	y_val -= end_size.y
	
	sustain.points[0] = Vector2.ZERO
	sustain.points[-1] = Vector2(0, max(y_val, 0))
	
	clipRect.position.x = -(end_size.x * 0.5)
	clipRect.size.x = end_size.x
	clipRect.size.y = y_val + end_size.y
	
	end.position.x = end_size.x * 0.5
	end.position.y = y_val + (end_size.y * 0.5)
