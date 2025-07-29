class_name FunkinCamera extends Camera2D

var color:Color = ProjectSettings.get_setting("engine/default_bg_color", Color.BLACK)

func _draw():
	var rect_pos:Vector2 = Vector2(FunkinGame.DEFAULT_WINDOW_SIZE.x * 0.5, FunkinGame.DEFAULT_WINDOW_SIZE.y * 0.5)
	var rect_size:Vector2 = Vector2(FunkinGame.DEFAULT_WINDOW_SIZE.x / zoom.x, FunkinGame.DEFAULT_WINDOW_SIZE.y / zoom.y)
	rect_pos /= zoom
	draw_rect(Rect2(-rect_pos.x, -rect_pos.y, rect_size.x, rect_size.y), color)

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
	queue_redraw()
	position = position.lerp(focus_marker.position, (1.0 - pow(1.0 - follow_lerp, delta * 60)))
	zoom = zoom.lerp(Vector2(zoom_val, zoom_val), (1.0 - pow(1.0 - zoom_lerp, delta * 60)))

#func is_close_vec(a: Vector2, b: Vector2, tolerance: float = 0.01) -> bool: return a.distance_to(b) <= tolerance

var do_bumping:bool = false
var bump_strength:float = 1
var bump_intensity:float = 0.015

var bump_interval:int = 4

func beat_hit(cur_beat:int):
	if cur_beat == 0 or !do_bumping or (cur_beat % bump_interval != 0): return
	zoom += Vector2(bump_intensity * bump_strength, bump_intensity * bump_strength)
