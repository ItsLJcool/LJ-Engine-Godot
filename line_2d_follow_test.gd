extends Node2D

@onready var notePath: Line2D = $"../PathToFollow"

@onready var sprite:Sprite2D = $sprite
@onready var sustain:Line2D = $sustain

var strumTime:float = 2500  # When the note is hit
var susLengh:float = 200

var temp_song_position:float = 0

var max_scroll_time = 1500.0
func _process(delta:float):
	temp_song_position += delta * 1000
	
	var path_length:int = notePath.points.size()
	if path_length < 2: return
	
	var path_points := notePath.points.duplicate()
	
	var distance:float = strumTime - temp_song_position
	var t:float = -((path_length - 1) * min(path_points[-1].y, distance)) / 1500
	
	if (t > 1):
		self.global_position.y = distance
		return
	self.global_position = get_path_position(notePath, t)


func get_path_position(path:Line2D, percent:float) -> Vector2:
	var total_length:float = 0.0
	var segment_lengths:Array[float] = []
	
	for i in range(path.points.size() - 1):
		var segment_len = path.points[i].distance_to(path.points[i + 1])
		segment_lengths.append(segment_len)
		total_length += segment_len
	
	var target_distance:float = percent * total_length
	var distance_covered:float = 0.0
	
	for i in range(segment_lengths.size()):
		var seg_len = segment_lengths[i]
		if distance_covered + seg_len >= target_distance:
			var t = (target_distance - distance_covered) / seg_len
			return path.points[i].lerp(path.points[i + 1], t)
		distance_covered += seg_len

	return path.points[-1]  # fallback
