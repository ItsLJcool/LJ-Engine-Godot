@tool
class_name Character extends AnimatedSprite2D

const CHARACTER_SCENE:PackedScene = preload("res://Funkin/Game/Character.tscn")
static func create(char_name:String = "bf")->Character:
	var new_char:Character = CHARACTER_SCENE.instantiate()
	new_char.change_character(char_name)
	return new_char

@onready var camera_position:Marker2D = $CameraPosition

## Path defining where the character's .tres animation is located
const CHARACTER_PATH:String = &"res://Assets/Characters/%s/%s"

var hold_time:float = 0

var sing_steps:float = 4

## The Node's Current Character to use for the .tres SpriteFrames
var cur_character:String = "bf"

var scale_factor:float = 1

## Changes the character to a new one
func change_character(new_character:String):
	cur_character = new_character
	load_animation()
	centered = false
	scale = Vector2.ONE * scale_factor

func _ready() -> void:
	if (Engine.is_editor_hint()):
		change_character(cur_character)
		dance()
		return
	dance()
	Conductor.beat_hit.connect(beatHit)

#region Animation and SpriteFrames

var animation_offsets:Dictionary[String, Vector2] = {}
func set_anim_offset(anim:String, offsetPos:Vector2)->void: animation_offsets[anim] = offsetPos
func get_anim_offset(anim:String)->Vector2: return animation_offsets[anim] if (animation_offsets.has(anim)) else Vector2.ZERO

## Removes any trailing numbers with index. example: idle0001 -> idle
func get_base_anim_name(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int(): i -= 1
	return animName.substr(0, i + 1)

## Gets all the XML information of the animations and packs it into a Dictonary
## {rect:Rect2i, frame:Rect2i, isRotated:bool}
func get_xml_animations(xml_path:String)->Dictionary:
	var animations:Dictionary = {}
	
	var xml = XMLParser.new()
	var error = xml.open(xml_path)
	if error != OK:
		push_error("Failed to open XML file: %s" % xml_path)
		return animations
	
	while xml.read() == OK:
		if !(xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "SubTexture"): continue
		var anim_name:String = get_base_anim_name(xml.get_named_attribute_value_safe("name"))
		
		var isRotated:bool = xml.get_named_attribute_value_safe("rotated") == "true"
		
		var x:int = xml.get_named_attribute_value("x").to_int()
		var y:int = xml.get_named_attribute_value("y").to_int()
		
		var w:int = xml.get_named_attribute_value("width").to_int()
		var h:int = xml.get_named_attribute_value("height").to_int()
		
		var frameWidth:int = w if !xml.has_attribute("frameWidth") else  xml.get_named_attribute_value("frameWidth").to_int()
		var frameHeight:int = h if !xml.has_attribute("frameHeight") else xml.get_named_attribute_value("frameHeight").to_int()
		
		var frameX:int = 0 if !xml.has_attribute("frameX") else xml.get_named_attribute_value("frameX").to_int()
		var frameY:int = 0 if !xml.has_attribute("frameY") else xml.get_named_attribute_value("frameY").to_int()
		
		if !animations.has(anim_name): animations[anim_name] = []
		animations[anim_name].append({
			"rect": Rect2i(x, y, w, h),
			"frame": Rect2i(frameX, frameY, frameWidth, frameHeight),
			"isRotated": isRotated
		})
	
	return animations

func get_animation_offsets()->Dictionary[String, Dictionary]:
	var xml_path:String = CHARACTER_PATH % [cur_character, "animation.xml"]
	var animation_data:Dictionary[String, Dictionary] = {}
	
	var xml = XMLParser.new()
	var error = xml.open(xml_path)
	if error != OK:
		push_error("Failed to open XML file: %s" % xml_path)
		return animation_data
	
	while xml.read() == OK:
		if (xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "character"):
			if (xml.has_attribute("scale")): scale_factor = xml.get_named_attribute_value("scale").to_float()
			flip_h = xml.get_named_attribute_value_safe("flipX") == "true"
			flip_v = xml.get_named_attribute_value_safe("flipY") == "true"
		
		if (xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "anim"):
			var animName = xml.get_named_attribute_value_safe("name")
			if (animName == "" || animation_data.has(animName)): continue
			animation_data[animName] = {
				"fps": (0 if !xml.has_attribute("fps") else xml.get_named_attribute_value("fps").to_int()),
				"loop": (xml.get_named_attribute_value_safe("loop") == "true"),
				"offset": Vector2((0 if !xml.has_attribute("x") else xml.get_named_attribute_value("x").to_int()), (0 if !xml.has_attribute("y") else xml.get_named_attribute_value("y").to_int()))
			}
	return animation_data;

func load_animation()->void:
	var png_path:String = CHARACTER_PATH % [cur_character, "spritesheet.png"]
	
	var base_image:Texture2D = load(png_path)
	if base_image == null:
		push_error("Failed to load image.")
		return
	
	var animations := get_xml_animations(CHARACTER_PATH % [cur_character, "spritesheet.xml"])
	var amim_offsets := get_animation_offsets()
	
	var shared_keys := animations.keys()
	shared_keys = shared_keys.filter(func(key): return amim_offsets.has(key))
	for key in animations.keys(): if not shared_keys.has(key): animations.erase(key)
	for key in amim_offsets.keys(): if not shared_keys.has(key): amim_offsets.erase(key)
	
	sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var texture_cache:Dictionary = {}
	for anim in animations.keys():
		var anim_data = amim_offsets[anim]
		set_anim_offset(anim, anim_data.offset)
		sprite_frames.add_animation(anim)
		sprite_frames.set_animation_speed(anim, anim_data.fps)
		sprite_frames.set_animation_loop(anim, anim_data.loop)
		
		for data in animations[anim]:
			var rect = data.rect
			var _frame = data.frame;
			var rect_key:String = ("%d,%d,%d,%d|%d,%d,%d,%d" % [
				rect.position.x, rect.position.y, rect.size.x, rect.size.y,
				_frame.position.x, _frame.position.y, _frame.size.x, _frame.size.y,
			])
			
			var animTexture:AtlasTexture
			if texture_cache.has(rect_key): animTexture = texture_cache[rect_key]
			else:
				animTexture = AtlasTexture.new()
				animTexture.atlas = base_image
				animTexture.filter_clip = true
				animTexture.region = rect
				animTexture.margin = Rect2i(-_frame.position, _frame.size - rect.size)
				texture_cache[rect_key] = animTexture
			
			sprite_frames.add_frame(anim, animTexture)
#endregion

func direction_to_sing(dir:Strum.NoteDirection):
	match dir % 4:
		0: return "left"
		1: return "down"
		2: return "up"
		3: return "right"

# I don't really like how this works but it works for now??
# someone please fix it if they have better ideas 🙏

func sing(dir:Strum.NoteDirection):
	var anim:String = direction_to_sing(dir)
	hold_time = sing_steps * (Conductor.step_crochet * 0.001)
	playAnim("sing"+anim.to_upper())

func playAnim(anim:String):
	offset = get_anim_offset(anim)
	play(anim)

func beatHit(_curBeat:int):
	dance()

func dance():
	if hold_time > 0 or is_playing(): return
	playAnim("idle")

func _process(delta: float) -> void:
	if hold_time > 0: hold_time -= delta

func is_singing()->bool: return animation.begins_with("sing")
