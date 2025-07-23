extends Node2D

# TODO: turn this into the Character Editor??

func _ready() -> void:
	create_spriteframes_from_xml("res://Assets/Notes/default/static")
	pass

## Removes any trailing numbers with index. example: idle0001 -> idle
func get_base_anim_name(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int(): i -= 1
	return animName.substr(0, i + 1)

func get_xml_animations(xml_path:String)->Dictionary:
	var animations:Dictionary = {}
	
	var xml = XMLParser.new()
	var error = xml.open(xml_path)
	if error != OK:
		push_error("Failed to open XML file: %s" % xml_path)
		return animations
	
	while xml.read() == OK:
		if !(xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "SubTexture"): continue
		var xmlName:String = xml.get_named_attribute_value("name")
		
		var isRotated:bool = false
		if xml.has_attribute("rotated"): isRotated = true if xml.get_named_attribute_value("rotated") == "true" else false
		
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
			"frame": Rect2i(-frameX, -frameY, (frameWidth - w) - frameX, (frameHeight - h) - frameY),
			"isRotated": isRotated
		})
	
	return animations

func get_xml_animation_by_name(xml_path:String, anim_name:String):
	var animation:Dictionary = {}
	
	var xml = XMLParser.new()
	var error = xml.open(xml_path)
	if error != OK:
		push_error("Failed to open XML file: %s" % xml_path)
		return animation
	
	while xml.read() == OK:
		if !(xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "SubTexture"): continue
		var xml_anim:String = get_base_anim_name(xml.get_named_attribute_value("name"))
		if xml_anim != anim_name: continue
		
		var isRotated:bool = false
		if xml.has_attribute("rotated"): isRotated = true if xml.get_named_attribute_value("rotated") == "true" else false
		
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
		
		if !animation.has(anim_name): animation[anim_name] = []
		animation[anim_name].append({
			"rect": Rect2i(x, y, w, h),
			"frame": Rect2i(-frameX, -frameY, (frameWidth - w) - frameX, (frameHeight - h) - frameY),
			"isRotated": isRotated
		})
	
	return animation

func create_spriteframes_from_xml(path:String)->void:
	var xml_path:String = "%s.xml" % path
	var png_path:String = "%s.png" % path
	
	var base_image:Texture2D = load(png_path)
	if base_image == null:
		push_error("Failed to load image.")
		return
	
	var xml = XMLParser.new()
	var error = xml.open(xml_path)
	if error != OK:
		push_error("Failed to open XML file: %s" % xml_path)
		return
	
	var animations:Dictionary = get_xml_animations(xml_path)
	var sprite_frames:SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	# Rect2 string => AtlasTexture
	var texture_cache:Dictionary = {}
	for anim in animations.keys():
		sprite_frames.add_animation(anim)
		sprite_frames.set_animation_speed(anim, 24)
		sprite_frames.set_animation_loop(anim, false)
		
		for data in animations[anim]:
			var rect = data.rect
			var frame = data.frame
			var rect_key:String = "%d,%d,%d,%d" % [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
			
			var animTexture:AtlasTexture
			if texture_cache.has(rect_key): animTexture = texture_cache[rect_key]
			else:
				animTexture = AtlasTexture.new()
				animTexture.atlas = base_image
				animTexture.filter_clip = true
				animTexture.region = rect
				animTexture.margin = frame
				texture_cache[rect_key] = animTexture
			
			sprite_frames.add_frame(anim, animTexture)
	
	
	var output_path:String = "%s.tres" % path
	ResourceSaver.save(sprite_frames, output_path)
	print("Saved to: ", output_path)
