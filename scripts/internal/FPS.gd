class_name FPS extends CanvasLayer

var normal_color:Color = Color(1, 1, 1)
var below_color:Color = Color(1, 0, 0)
var average_color:Color = Color(1, 1, 0)

var text_display:String = " FPS: %d \n VRAM: %s / %s \n Memory: %s / %s \n\n Godot %s"

var time:float = 0

var counter:RichTextLabel = RichTextLabel.new()

func _ready():
	counter.position = Vector2(5, 5)
	counter.size = Vector2(350, 200)
	counter.add_theme_font_size_override("normal_font_size", 22)
	add_child(counter)

var max_mem:float = 0.0
var max_text_mem:float = 0.0
func _process(delta:float):
	var fps:float = Engine.get_frames_per_second()
	var tex_mem:float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var real_mem:float = Performance.get_monitor(Performance.MEMORY_STATIC)
	
	if real_mem > max_mem: max_mem = real_mem
	if tex_mem > max_text_mem: max_text_mem = tex_mem
	
	@warning_ignore("NARROWING_CONVERSION")
	counter.text = (text_display %
	[fps,
	String.humanize_size(tex_mem), String.humanize_size(max_text_mem),
	String.humanize_size(real_mem), String.humanize_size(max_mem),
	Engine.get_version_info().string] )
	
	var current_color:Color = normal_color
	
	if fps < 30:
		time = 0
		current_color = below_color
	elif fps < 60:
		time = 0
		current_color = average_color
	else: time = 0
	
	if time < 1: time += delta * 10
	
	counter.modulate = counter.modulate.lerp(current_color, time)
