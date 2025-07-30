## Resource container from your XML
class_name AnimationFrame extends Resource

@export var rect:Rect2i = Rect2i() ## The animation's position in the Texture, and the bounding box
@export var frame:Rect2i = Rect2i() ## The offset for the animation

@export var meta:Dictionary = {} ## Any extra infromation you want to save here... for some reason
