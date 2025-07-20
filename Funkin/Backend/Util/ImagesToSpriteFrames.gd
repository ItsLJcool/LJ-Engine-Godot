extends Node2D

func _ready() -> void:
	create_spriteframes_from_xml("res://Assets/Notes/default/static")

# Remove trailing digits from the frame name
func get_base_anim_name(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int():
		i -= 1
	return animName.substr(0, i + 1)
	
func create_spriteframes_from_xml(imageXmlPath:String):
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
			var xmlName = xml.get_named_attribute_value("name")
			var x = xml.get_named_attribute_value("x").to_int()
			var y = xml.get_named_attribute_value("y").to_int()
			var w = xml.get_named_attribute_value("width").to_int()
			var h = xml.get_named_attribute_value("height").to_int()

			var anim_name := get_base_anim_name(xmlName)
			if !animations.has(anim_name): animations[anim_name] = []
			animations[anim_name].append(Rect2(x, y, w, h))

	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	for anim in animations.keys():
		sprite_frames.add_animation(anim)
		sprite_frames.set_animation_speed(anim, 24)
		sprite_frames.set_animation_loop(anim, false)
		for rect in animations[anim]:
			var frame_image := base_image.get_region(rect)
			var tex := ImageTexture.create_from_image(frame_image)
			sprite_frames.add_frame(anim, tex)

	var output_path:String = "%s.tres" % imageXmlPath
	ResourceSaver.save(sprite_frames, output_path)
	print("Saved to: ", output_path)
