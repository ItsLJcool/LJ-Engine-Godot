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
	scale = Vector2.ONE * scale_factor

func _ready() -> void:
	if (Engine.is_editor_hint()):
		change_character(cur_character)
		return
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

func get_character_data()->AnimationContainer: return load(CHARACTER_PATH % [cur_character, "animation.res"])

func load_animation()->void:
	var png_path:String = CHARACTER_PATH % [cur_character, "spritesheet.png"]
	
	var base_image:Texture2D = load(png_path)
	if base_image == null:
		push_error("Failed to load image.")
		return
	
	var char_data:AnimationContainer = get_character_data()
	for anim_name:String in char_data.animation_data.keys(): set_anim_offset(anim_name, char_data.animation_data.get(anim_name, []).offset)
	
	scale = Vector2.ONE * char_data.size
	position = char_data.position
	flip_h = char_data.flip_x
	flip_v = char_data.flip_y
	
	sprite_frames = AnimationContainer.convert_to_spriteframes(char_data, base_image)
	
	dance()
#endregion

@export_tool_button("Refresh SpriteSheet") var reload = load_animation
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
