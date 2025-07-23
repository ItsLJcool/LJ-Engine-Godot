class_name Character extends AnimatedSprite2D

## Path defining where the character's .tres animation is located
const CHARACTER_PATH:String = &"res://Assets/Characters/%s.tres"

var lastHit:float = -INF
var holdTime:float = 0

## The Node's Current Character to use for the .tres SpriteFrames
var curCharacter:String = "bf"

var scaleFactor:float = 0.5

## Changes the character to a new one
func change_character(new_character:String):
	sprite_frames = load(CHARACTER_PATH % new_character)
	centered = false
	scale *= scaleFactor
	
	curCharacter = new_character


func _ready() -> void:
	change_character(curCharacter)
	dance()
	Conductor.beat_hit.connect(beatHit)

# TODO:
# Make Character dance when not playing notes, and make the Singing animations based off of V-Slice pls 🙏
func beatHit(_curBeat:int):
	if !(lastHit + (Conductor.step_crochet) < Conductor.song_position): return
	dance()

func dance():
	lastHit = Conductor.song_position
	play("idle")
