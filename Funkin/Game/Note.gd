class_name Note extends Node2D

#region Initalize Variable Names

@onready var sprite:AnimatedSprite2D = $Sprite ## The "Note" Sprite Itself. Not the Root Class for independent rotations.
@onready var sustain:Line2D = $Sustain ## Your Sustain. Instead of like 5 billion seperate images 🔥
@onready var clipRect:Control = $Sustain/ClipRect ## Used for clipping the end Sprite2D when hitting the full sustain
@onready var end:Sprite2D = $Sustain/ClipRect/End ## The end tail piece

var sustainsPath:String = "res://Assets/Notes/%s/sustains/%s-sustain.png" ## Path for your sustain Images. use %s for the direction name
var endPath:String = "res://Assets/Notes/%s/sustains/%s-end.png" ## Path for your end Images. use %s for the direction name

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

var earlyPressWindow:float = 0.5 ## Placeholder Information. I have no clue what this does
var latePressWindow:float = 1 ## Placeholder Information. I have no clue what this does

var canBeHit:bool = false ## If the note can be hit when in range of the Static Strum
var tooLate:bool = false ## If the note was too late to be hit
var wasGoodHit:bool = false ## If the note was hit

var hitWindow:float = 160; ## Time im MS of the window you have to hit the note

var avoid:bool = false; ## If true, hitting the note counts as a miss
#endregion

func init(_strum:Strum, time:float, sustainLength:float)->void: ## Initalizing the Note to be used
	self.visible = false
	
	strum = _strum
	strumTime = time
	susLength = sustainLength
	
	if (sprite.sprite_frames.get_meta("use_rotation")):
		match strum.direction:
			Strum.NoteDirection.DOWN, Strum.NoteDirection.UP: sprite.rotation_degrees -= 90
	
	var dirName:String = Strum.direction_to_string(strum.direction)
	sprite.play(dirName)
	sustain.texture = load(sustainsPath % ["default", dirName])
	end.texture = load(endPath % ["default", dirName])

func _ready():
	if (!Engine.is_editor_hint()): clipRect.clip_contents = true;
	self.position.y = -5000
	
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
		strum.strumLine.play_character_animation("sing"+strum.direction_to_string(strum.direction).to_upper())

# Ok reference to everyone here:
# Hitting a sustain like normal but releasing it early should cause it to never be hittable again.
# Thats how I want the engine to handle sustains.
func update_note()->void: ## Call this to update position progression, and if the note should be hittable
	@warning_ignore("integer_division")
	self.position.y = (strumTime - Conductor.song_position) * (0.6 * (int(strum.scrollSpeed * 100) / 100) )
	
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
	
	if isSustainNote: update_sustain()

func update_sustain()->void: ## Updates the Length of the sustain when hitting or not hitting.
	var point_count:int = sustain.get_point_count()
	var last_point:Vector2 = sustain.get_point_position(point_count-1)
	
	var endSize:Vector2 = Vector2(end.texture.get_width(), end.texture.get_height())
	
	var lengthPog:float = (0.6 * round(strum.scrollSpeed * 100) / 100)
	var y_val:float = 0.0
	
	if wasGoodHit:
		y_val = ((susLength + (strumTime - Conductor.song_position)) * lengthPog)
		sustain.position.y = -(position.y - strum.position.y)
	else:
		y_val = (susLength * lengthPog)
		sustain.position.y = 0
	
	y_val -= endSize.y
	
	last_point.y = max(y_val, 0)
	
	sustain.set_point_position(point_count-1, last_point)
	
	clipRect.position.x = -(endSize.x * 0.5)
	clipRect.size.x = endSize.x
	clipRect.size.y = y_val + endSize.y
	
	end.position.x = endSize.x * 0.5
	end.position.y = y_val
