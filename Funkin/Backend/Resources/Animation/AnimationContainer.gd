## Resource container for your Character itself
class_name AnimationContainer extends Resource

@export var size:float = 1 ## The Character's Size
@export var flip_x:bool = false ## Flip's the Character on the X Axis
@export var flip_y:bool = false ## Flip's the Character on the Y Axis

@export var position:Vector2 = Vector2.ZERO ## Set the Position of the character in the Scene

@export var animation_data:Dictionary[String, AnimationData] = {} ## Contains your Animation with their name, and their assosiated data

@export var meta:Dictionary = {} ## Any extra infromation you want to save here

static func convert_to_spriteframes(char_data:AnimationContainer, base_image:Texture2D)->SpriteFrames:
	var sprite_frames:SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var texture_cache:Dictionary = {}
	for anim_name:String in char_data.animation_data.keys():
		var anim:AnimationData = char_data.animation_data.get(anim_name, [])
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, anim.fps)
		sprite_frames.set_animation_loop(anim_name, anim.loop)
		
		for key:String in char_data.meta.keys(): sprite_frames.set_meta(key, char_data.meta[key])
		
		for data:AnimationFrame in anim.frame_data:
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
			
			sprite_frames.add_frame(anim_name, animTexture)
		
	return sprite_frames
