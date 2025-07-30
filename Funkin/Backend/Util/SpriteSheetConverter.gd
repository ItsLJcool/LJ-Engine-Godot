extends Node2D

@onready var folder_path:FileDialog = $FileDialog

## Removes any trailing numbers with index. example: idle0001 -> idle
func get_base_anim_name(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int(): i -= 1
	return animName.substr(0, i + 1)

## Gets all the XML information of the animations and packs it into a Dictonary
## {rect:Rect2i, frame:Rect2i, isRotated:bool}
func get_xml_animations(xml_path:String)->Dictionary[String, Array]:
	var animations:Dictionary[String, Array] = {}
	
	var xml = XMLParser.new()
	var error = xml.open(xml_path)
	if error != OK:
		push_error("Failed to open XML file: %s" % xml_path)
		return animations
	
	while xml.read() == OK:
		if !(xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "SubTexture"): continue
		var anim_name:String = xml.get_named_attribute_value_safe("name")
		var formated_name = get_base_anim_name(anim_name)
		
		#var isRotated:bool = xml.get_named_attribute_value_safe("rotated") == "true"
		
		var x:int = xml.get_named_attribute_value("x").to_int()
		var y:int = xml.get_named_attribute_value("y").to_int()
		
		var w:int = xml.get_named_attribute_value("width").to_int()
		var h:int = xml.get_named_attribute_value("height").to_int()
		
		var frameWidth:int = w if !xml.has_attribute("frameWidth") else  xml.get_named_attribute_value("frameWidth").to_int()
		var frameHeight:int = h if !xml.has_attribute("frameHeight") else xml.get_named_attribute_value("frameHeight").to_int()
		
		var frameX:int = 0 if !xml.has_attribute("frameX") else xml.get_named_attribute_value("frameX").to_int()
		var frameY:int = 0 if !xml.has_attribute("frameY") else xml.get_named_attribute_value("frameY").to_int()
		
		var frame_array = animations.get_or_add(formated_name, [])
		frame_array.push_back({
			"rect": Rect2i(x, y, w, h),
			"frame": Rect2i(frameX, frameY, frameWidth, frameHeight),
			#"isRotated": isRotated
		})
	
	return animations

# The folder path
func parse_and_save(path:String, xml_name:String = "spritesheet.xml", output_name:String = "animation"):
	var xml_path:String = path % xml_name
	
	var animations:Dictionary = get_xml_animations(xml_path)
	
	var file:AnimationContainer = AnimationContainer.new()
	
	var cache:Dictionary = {}
	for _name:String in animations:
		var anim_data:AnimationData = AnimationData.new()
		
		for data:Dictionary in animations.get(_name, []):
			var rect = data.rect
			var frame = data.frame
			var key:String = ("%d,%d,%d,%d|%d,%d,%d,%d" % [
				rect.position.x, rect.position.y, rect.size.x, rect.size.y,
				frame.position.x, frame.position.y, frame.size.x, frame.size.y,
			])
			
			var anim_frame:AnimationFrame
			if cache.has(key): anim_frame = cache.get(key)
			else:
				anim_frame = AnimationFrame.new()
				anim_frame.rect = rect
				anim_frame.frame = frame
				cache.set(key, anim_frame)
			
			anim_data.frame_data.push_back(anim_frame)
		
		file.animation_data.set(_name, anim_data)
	
	var flags:int = 0 | ResourceSaver.SaverFlags.FLAG_OMIT_EDITOR_PROPERTIES | ResourceSaver.SaverFlags.FLAG_COMPRESS
	
	ResourceSaver.save(file, path % (output_name+".res"), flags)

func _on_file_dialog_dir_selected(dir: String) -> void:
	parse_and_save(dir + "/%s")

func _on_file_dialog_file_selected(path: String) -> void:
	var last_split := path.rsplit("/")[-1]
	parse_and_save(path.trim_suffix(last_split) + "/%s", last_split, last_split.trim_suffix(".xml"))
