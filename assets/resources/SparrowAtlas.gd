class_name SparrowAtlas extends Resource

# Goal of this class is to make it so you convert XML + Texture into 1 .res file that contains the SpriteFrames + Texture (or if possible just the SpriteFrames)
# Should also support rotated textures, well see tho.

# Note that you call the static functions for parsing and it returns the SpriteFrames
# This code is somewhat based off of my experiences and cherrythecool's FunkinGodot project for the rotating texture implementation.

@export var sprite_frames:SpriteFrames = null
@export var animation_offsets:Dictionary[String, Vector2] = {}
## TODO: Save the texture / embedded into the file so we don't need more than 1 file reference when publishing
#@export var texture:CompressedTexture2D = null

static var save_flags:int = ResourceSaver.FLAG_COMPRESS

static var export_type:String = ".tres"

static func _load(path:String) -> SparrowAtlas:
	path = path.get_basename()
	
	if FileAccess.file_exists(path+".tres"): return load(path+".tres") as SparrowAtlas
	else: return SparrowAtlas.new(path)

func _init(path = null) -> void:
	if path == null: return
	path = path.get_basename()
	
	if sprite_frames != null: return
	sprite_frames = parse_xml(path+".xml")
	ResourceSaver.save(self, path+".tres", save_flags)

static func parse_xml(path: String) -> SpriteFrames:
	assert(FileAccess.file_exists(path), "File needs to exist.")
	assert(path.get_extension() == "xml", "File Needs to be an XML")
	
	var _sprite_frames:SpriteFrames = SpriteFrames.new()
	if _sprite_frames.has_animation(&"default"): _sprite_frames.remove_animation(&"default")
	
	var xml_parser:XMLParser = XMLParser.new()
	xml_parser.open(path)
	
	var source_image:Image = null
	var source_texture:CompressedTexture2D = null
	
	var sparrow_frames:Array[SparrowFrame] = []
	
	while xml_parser.read() != ERR_FILE_EOF:
		if xml_parser.get_node_type() != XMLParser.NODE_ELEMENT: continue
		var node_name: String = xml_parser.get_node_name().to_lower()
		
		# This is from FunkinGodot tysm
		# Modified a bit tho
		match node_name:
			"textureatlas":
				var texture_path: String = "%s/%s" % [
					path.get_base_dir(),
					xml_parser.get_named_attribute_value_safe("imagePath"),
				]
				
				if not ResourceLoader.exists(texture_path):
					texture_path = "%s.png" % [path.get_basename()]
				
				if ResourceLoader.exists(texture_path):
					source_texture = load(ResourceUID.path_to_uid(texture_path))
			"subtexture":
				var frame:SparrowFrame = SparrowFrame.new()
				_parse_subtexture(frame, xml_parser, sparrow_frames, source_image, source_texture)
				if not _sprite_frames.has_animation(frame.animation_name):
					_sprite_frames.add_animation(frame.animation_name)
					_sprite_frames.set_animation_loop(frame.animation_name, false)
					_sprite_frames.set_animation_speed(frame.animation_name, 24)
				sparrow_frames.push_back(frame)
	
	sparrow_frames.sort_custom(func(a: SparrowFrame, b: SparrowFrame) -> bool:
		return a.animation_frame < b.animation_frame
	)
	
	for data in sparrow_frames: _sprite_frames.add_frame(data.animation_name, data.atlas)
	
	return _sprite_frames

static func _parse_subtexture(frame:SparrowFrame, xml_parser:XMLParser, sparrow_frames:Array[SparrowFrame], source_image:Image, source_texture:CompressedTexture2D):
	assert(xml_parser.has_attribute("name"), "SubTexture needs \"name\" attribute to be parsed as a frame.")
	assert(xml_parser.has_attribute("x"), "SubTexture needs \"x\" attribute to be parsed as a frame.")
	assert(xml_parser.has_attribute("y"), "SubTexture needs \"y\" attribute to be parsed as a frame.")
	assert(xml_parser.has_attribute("width"), "SubTexture needs \"width\" attribute to be parsed as a frame.")
	assert(xml_parser.has_attribute("height"), "SubTexture needs \"height\" attribute to be parsed as a frame.")
	
	var frame_name: String = xml_parser.get_named_attribute_value("name")
	var frame_name_array: PackedStringArray = parse_animation_name(frame_name)
	var parsed_name: String = frame_name_array[0]
	var parsed_numbers: String = frame_name_array[1]

	var frame_rotated: String = xml_parser.get_named_attribute_value_safe("rotated")

	var frame_x: String = xml_parser.get_named_attribute_value("x")
	var frame_y: String = xml_parser.get_named_attribute_value("y")
	var frame_width: String = xml_parser.get_named_attribute_value("width")
	var frame_height: String = xml_parser.get_named_attribute_value("height")

	assert(frame_x.is_valid_int(), "SubTextures must have a valid \"x\" coordinate to be parsed correctly.")
	assert(frame_y.is_valid_int(), "SubTextures must have a valid \"y\" coordinate to be parsed correctly.")
	assert(frame_width.is_valid_int(), "SubTextures must have a valid \"width\" coordinate to be parsed correctly.")
	assert(frame_height.is_valid_int(), "SubTextures must have a valid \"height\" coordinate to be parsed correctly.")
	
	frame.animation_name = parsed_name
	frame.animation_frame = parsed_numbers.to_int()
	
	frame.source = Rect2(
		Vector2(float(frame_x), float(frame_y)) ,
		Vector2(float(frame_width), float(frame_height)),
	)
	
	frame.offsets = Rect2(Vector2.ZERO, Vector2.ZERO)
	
	frame.rotated = (frame_rotated == "true")
	
	if frame.rotated: frame.source.size = Vector2(frame.source.size.y, frame.source.size.x)

	var offset_x: String = xml_parser.get_named_attribute_value_safe("frameX")
	var offset_y: String = xml_parser.get_named_attribute_value_safe("frameY")
	var bounds_width: String = xml_parser.get_named_attribute_value_safe("frameWidth")
	var bounds_height: String = xml_parser.get_named_attribute_value_safe("frameHeight")
	
	if offset_x.is_valid_float() and bounds_width.is_valid_float():
		frame.offsets.position.x = absf(float(offset_x)); @warning_ignore("NARROWING_CONVERSION")
		frame.offsets.size.x = float(bounds_width) - frame.source.size.x; @warning_ignore("NARROWING_CONVERSION")
	
	if offset_y.is_valid_float() and bounds_height.is_valid_float():
		frame.offsets.position.y = absf(float(offset_y)); @warning_ignore("NARROWING_CONVERSION")
		frame.offsets.size.y = float(bounds_height) - frame.source.size.y; @warning_ignore("NARROWING_CONVERSION")

	for checked_frame:SparrowFrame in sparrow_frames:
		if checked_frame.source == frame.source and checked_frame.offsets == frame.offsets and checked_frame.rotated == frame.rotated:
			frame.atlas = checked_frame.atlas
			break
	
	if frame.atlas == null:
		frame.atlas = AtlasTexture.new()
		
		if frame.rotated:
			if not is_instance_valid(source_image): source_image = source_texture.get_image()
			
			var image:Image = source_image.get_region(Rect2(
				frame.source.position,
				Vector2(frame.source.size.y, frame.source.size.x)
			))
			image.rotate_90(COUNTERCLOCKWISE)
			frame.atlas.atlas = ImageTexture.create_from_image(image)
			frame.atlas.region = Rect2(Vector2.ZERO, frame.source.size)
			frame.atlas.margin = frame.offsets
		else:
			frame.atlas.atlas = source_texture
			frame.atlas.region = frame.source
			frame.atlas.margin = frame.offsets

		frame.atlas.filter_clip = true

static func parse_animation_name(frame_name: String) -> PackedStringArray:
	const NUMBERS: String = "0123456789"
	if frame_name.is_empty(): return ["", ""]
	
	var starting_numbers: bool = true
	var index: int = frame_name.length() - 1
	var stop_index: int = frame_name.length() - 1
	while index >= 0:
		var character: String = frame_name[index]
		if starting_numbers:
			if (not NUMBERS.contains(character)) or index < frame_name.length() - 4:
				starting_numbers = false
				stop_index = index + 1
				break
		
		index -= 1
	
	if starting_numbers: return ["", frame_name]
	
	return [
		frame_name.substr(0, stop_index),
		frame_name.substr(stop_index, frame_name.length() - 1)
	]

class SparrowFrame extends RefCounted:
	var animation_name: StringName
	var animation_frame:int

	var atlas:AtlasTexture = null

	var source: Rect2
	var offsets: Rect2
	
	var rotated:bool
	
