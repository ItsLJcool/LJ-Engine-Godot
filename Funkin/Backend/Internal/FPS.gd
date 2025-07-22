class_name FPS extends RichTextLabel

var normal_color:Color = Color(1, 1, 1)
var below_color:Color = Color(1, 0, 0)
var average_color:Color = Color(1, 1, 0)

var time:float = 0

var textDisplay:String = " FPS: %d \n VRAM: %s \n Memory: %s \n\n Godot %s"
func _process(delta:float):
	var fps = Engine.get_frames_per_second()
	var texMem = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var realMem = Performance.get_monitor(Performance.MEMORY_STATIC)
	
	self.text = (textDisplay %
	[fps, String.humanize_size(texMem), String.humanize_size(realMem), Engine.get_version_info().string] )
	
	var current_color:Color = normal_color
	
	if fps < 30:
		time = 0
		current_color = below_color
	elif fps < 60:
		time = 0
		current_color = average_color
	else: time = 0
	
	if time < 1: time += delta * 10
	
	self.modulate = self.modulate.lerp(current_color, time)
