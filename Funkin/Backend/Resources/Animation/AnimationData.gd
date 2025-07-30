## Resource Container for your Animation offsets, and what not
class_name AnimationData extends Resource

@export var loop:bool = false ## Should the Animation Loop
@export var fps:int = 24 ## How fast in frames is the animation

@export var offset:Vector2 = Vector2.ZERO ## The Animation's Offset

@export var frame_data:Array[AnimationFrame] = [] ## Frame Storage from the Spritesheet.xml

@export var meta:Dictionary = {} ## Any extra infromation you want to save here
