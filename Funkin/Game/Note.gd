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

var render:bool = false

var isSustainNote:bool = true

var susLength:float = 200:
	set(value):
		susLength = value
		if sustain and end:
			sustain.set_point_position(sustain.get_point_count()-1, Vector2(0, value))
			end.flip_v = true if value < 0 else false
			end.flip_h = end.flip_v
			end.position = sustain.position
			end.position.y += value

var strumTime:float = 3000

# The * 0.5 is so that it's easier to hit them too late, instead of too early
var earlyPressWindow:float = 0.5
var latePressWindow:float = 1

var canBeHit:bool = false
var tooLate:bool = false
var wasGoodHit:bool = false

var hitWindow:float = 160;

# To be avoided by botplay
var avoid:bool = false;
#endregion

func init(_strum:Strum, time:float, sustainLength:float):
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

var path_points:PackedVector2Array = []
func _ready():
	#if (!Engine.is_editor_hint()): clipRect.clip_contents = true;
	self.position.y = -5000
	
func deleteNote():
	self.queue_free()

func goodNoteHit():
	wasGoodHit = true
	
	#var noteDiff = abs(Conductor.song_position - strumTime);
	#var daRating:String = "sick";
	#var score:int = 300;
	#var accuracy:float = 1;
	
	if !isSustainNote:
		deleteNote()
	else:
		sprite.self_modulate.a = 0

func _process(delta: float) -> void:
	if !render: return
	path_points = strum.notePath.points.duplicate()
	update_note(delta)

var test:float = 0
func update_note(_delta:float):
	if (strumTime < path_points[-1].y): return
	self.position = update_path(self.position)
	#self.position.y = (strumTime - Conductor.song_position) * (0.45 * (int(strum.scrollSpeed * 100) / 100) )
	
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

var path_NodeIndex:int = -1
var path_NextNodeIndex:int = -1

var sustainPath_Amount:float = 5
func update_path(pos:Vector2)->Vector2:
	var path_length = path_points.size()
	
	if path_length <= 0: return pos
	if path_length == 1:
		var path_node = path_points[0]
		return Vector2(path_node.x, path_node.y)
	
	#@warning_ignore("integer_division")
	#var distance = (strumTime - Conductor.song_position) * (0.45 * (int(strum.scrollSpeed * 100) / 100))
	var distance = strumTime - Conductor.song_position
	
	var node_progress = ((path_length - 1) * min(path_points[-1].y, distance)) / 1500
	path_NodeIndex = int(floor(node_progress))
	path_NextNodeIndex = min(path_NodeIndex + 1, path_length - 1)
	var next_node_ratio = node_progress - path_NodeIndex
	
	if (path_NodeIndex < 0 or path_NextNodeIndex < 0): return Vector2(0, distance)
	
	var this_node = path_points[path_NodeIndex]
	var next_node = path_points[path_NextNodeIndex]

	var pos_x = lerp(this_node.x, next_node.x, next_node_ratio)
	var pos_y = lerp(this_node.y, next_node.y, next_node_ratio)
	return Vector2(pos_x, pos_y)

func updateSustain():
	if path_points.size() < 2: return

	var path_total = path_points.size()
	var sustain_points: Array[Vector2] = []
	
	var remaining_length = susLength
	var i = path_NodeIndex
	if i < 0: i = 0

	# Get starting point from interpolation
	var this_node = path_points[i]
	var next_node = path_points[min(i + 1, path_total - 1)]
	var progress = ((strumTime - Conductor.song_position) / (path_points[-1].y - path_points[0].y)) * (path_total - 1)
	var t = clamp(progress - i, 0.0, 1.0)
	var start_point = this_node.lerp(next_node, t)

	var current_pos = start_point
	sustain_points.append(to_local(current_pos))

	while i < path_total - 1 and remaining_length > 0:
		var p1 = path_points[i]
		var p2 = path_points[i + 1]

		if p1.distance_to(p2) == 0:
			i += 1
			continue

		var segment_dir = (p2 - p1).normalized()
		var segment_remaining = p2.distance_to(current_pos)

		if segment_remaining < remaining_length:
			current_pos = p2
			sustain_points.append(to_local(current_pos))
			remaining_length -= segment_remaining
			i += 1
		else:
			current_pos += segment_dir * remaining_length
			sustain_points.append(to_local(current_pos))
			remaining_length = 0
			break

	# Update Line2D
	sustain.clear_points()
	for p in sustain_points:
		sustain.add_point(p)

	# Update end sprite
	if sustain_points.size() >= 2:
		var end_pos = sustain_points[-1]
		var prev_pos = sustain_points[-2]
		end.position = end_pos
		end.rotation = (end_pos - prev_pos).angle()
