extends Node2D

func _ready() -> void:
	create_spriteframes_from_xml("res://Assets/Characters/bf")

# Remove trailing digits from the frame name
func get_base_anim_name(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int(): i -= 1
	return animName.substr(0, i + 1)

func create_spriteframes_from_xml(imageXmlPath:String)->void:
	var xmlPath = "%s.xml" % imageXmlPath
	var pngPath = "%s.png" % imageXmlPath
	
	var base_image := Image.load_from_file(pngPath)
	if base_image == null:
		push_error("Failed to load image.")
		return
	
	var xml = XMLParser.new()
	var error = xml.open(xmlPath)
	if error != OK:
		push_error("Failed to open XML file: %s" % xmlPath)
		return
	
	var animations := {}
	while xml.read() == OK:
		if xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "SubTexture":
			var xmlName:String = xml.get_named_attribute_value("name")
			var isRotated:bool = false
			# No boolean casting for strings yet rip
			if (xml.has_attribute("rotated")): isRotated = true if xml.get_named_attribute_value("rotated") == "true" else false
			var x:int = xml.get_named_attribute_value("x").to_int()
			var y:int = xml.get_named_attribute_value("y").to_int()
			
			var w:int = xml.get_named_attribute_value("width").to_int()
			var h:int = xml.get_named_attribute_value("height").to_int()
			
			var frameWidth:int = w
			var frameHeight:int = h
			if xml.has_attribute("frameWidth"): frameWidth = xml.get_named_attribute_value("frameWidth").to_int()
			if xml.has_attribute("frameHeight"): frameHeight = xml.get_named_attribute_value("frameHeight").to_int()
			
			var frameX:int = 0
			var frameY:int = 0
			if xml.has_attribute("frameX"): frameX = xml.get_named_attribute_value("frameX").to_int()
			if xml.has_attribute("frameY"): frameY = xml.get_named_attribute_value("frameY").to_int()
			
			var anim_name:String = get_base_anim_name(xmlName)
			if !animations.has(anim_name): animations[anim_name] = []
			animations[anim_name].append({
				"rect": Rect2i(x, y, w, h),
				"frame": Rect2i(frameX, frameY, frameWidth, frameHeight),
				"isRotated": isRotated
			})
	
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var texture_cache := {}  # Rect2 string => ImageTexture
	for anim in animations.keys():
		sprite_frames.add_animation(anim)
		sprite_frames.set_animation_speed(anim, 24)
		sprite_frames.set_animation_loop(anim, false)
		
		for data in animations[anim]:
			var rect = data.rect
			var frame = data.frame
			var rect_key := "%d,%d,%d,%d" % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
			
			var tex:ImageTexture
			if texture_cache.has(rect_key): tex = texture_cache[rect_key]
			else:
				tex = crop_with_offset(base_image, rect, frame, data.isRotated)
				texture_cache[rect_key] = tex
			
			sprite_frames.add_frame(anim, tex)
	
	
	var output_path:String = "%s.tres" % imageXmlPath
	ResourceSaver.save(sprite_frames, output_path)
	print("Saved to: ", output_path)

# I think what needs to be done is get the largest rect size in the animation, and offset based on size difference??
# literally so confused tho
func crop_with_offset(base_image:Image, crop_rect:Rect2i, frame:Rect2i, rotated:bool = false) -> ImageTexture:
	var new_size:Vector2i = Vector2i(crop_rect.size) + frame.position.abs()
	var dist:Vector2i = Vector2i(max(0, frame.position.x), max(0, frame.position.y))
	
	var padded:Image = Image.create_empty(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)
	padded.blit_rect(base_image.get_region(crop_rect), Rect2i(Vector2i.ZERO, crop_rect.size), dist)
	
	if rotated: padded.rotate_90(COUNTERCLOCKWISE)
	
	return ImageTexture.create_from_image(padded)
