extends CanvasLayer

@onready var fps_label = $FPSLabel
func _ready():
	_update_label()
	
func _process(delta):
	var fps = Engine.get_frames_per_second()
	var texMem = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var realMem = Performance.get_monitor(Performance.MEMORY_STATIC)
	fps_label.text = " FPS: %d \n VRAM: %s \n Memory: %s" % [fps, String.humanize_size(texMem), String.humanize_size(realMem)]
	if fps < 30:
		fps_label.modulate = Color(1, 0, 0)
	elif fps < 60:
		fps_label.modulate = Color(1, 1, 0)
	else:
		fps_label.modulate = Color(1, 1, 1)
	_update_label()
	
func _update_label():
	var font_size = int(get_viewport().size.x * 0.02)  
	var label_width = fps_label.get_minimum_size().x
	var viewport_size = get_viewport().size
	fps_label.position = Vector2(viewport_size.x - label_width - 230, 5)  
