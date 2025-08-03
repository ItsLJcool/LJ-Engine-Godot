class_name FunkinCamera extends Camera2D

var focus_marker:Marker2D = Marker2D.new()
func follow(marker:Marker2D): focus_marker = marker ## Quick setter to the focus_marker variable because yes
func snap_to_focus(): position = focus_marker.position ## Instantly set's the camera focus to where it's supposed to be.

var follow_lerp:float = 0.04:
	set(value): follow_lerp = clamp(value, 0, 1)

var zoom_lerp:float = 0.05:
	set(value): zoom_lerp = clamp(value, 0, 1)

var zoom_val:float = 1
func snap_zoom(): zoom = Vector2(zoom_val, zoom_val)

func _ready() -> void:
	zoom_val = zoom.x
	Conductor.beat_hit.connect(beat_hit)
	focus_marker.position = get_window().size * 0.5
	snap_to_focus()

func _process(delta: float) -> void:
	position = position.lerp(focus_marker.position, (1.0 - pow(1.0 - follow_lerp, delta * 60)))
	zoom = zoom.lerp(Vector2(zoom_val, zoom_val), (1.0 - pow(1.0 - zoom_lerp, delta * 60)))

@export var do_bumping:bool = true
var bump_strength:float = 1
var bump_intensity:float = 0.015

var bump_interval:int = 4

func beat_hit(cur_beat:int):
	if cur_beat == 0 or !do_bumping or (cur_beat % bump_interval != 0): return
	zoom += Vector2(bump_intensity * bump_strength, bump_intensity * bump_strength)
