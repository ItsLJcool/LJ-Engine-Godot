class_name FunkinGame extends Node

# lemme double check cuz I think im lying to myself
# I was right 🔥
@onready var UI_LAYER:CanvasLayer = $UILayer ## This will be your UI Layer. Moving the camera will not affect objects on this layer.
@onready var GAME_LAYER:Node = $Game ## This Node acts as a place to store game objects, so that your UI and game objects are seperated.

@onready var window:Window = get_window()

## This is your camera that the FunkinGame will render to.
@onready var camera:Camera2D = $Camera

## Adds your Node to the UI Layer. This will always render above the Game Layer
func add_UI(node:Node): UI_LAYER.add_child(node)
## Removes your Node from the UI Layer
func remove_UI(node:Node): UI_LAYER.remove_child(node)

## Adds your Node to the Game Layer. This will always render below the UI Layer
func add(node:Node): GAME_LAYER.add_child(node)
## Removes your Node from the Game Layer.
func remove(node:Node): GAME_LAYER.remove_child(node)

func _ready():
	# So the camera is always in the center on start-up no matter what
	camera.position = window.size * 0.5
