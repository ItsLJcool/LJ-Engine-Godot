# Ok this class is basically inspired from Flixel, but trust me I think it will be good to have this here.
# We can make Custom Loading Screens, UI Elements, Utilities, etc.
class_name FunkinGame extends Node

static var instance:FunkinGame

# lemme double check cuz I think im lying to myself
# I was right 🔥
@onready var UI_LAYER:CanvasLayer = $UILayer ## This will be your UI Layer. Moving the camera will not affect objects on this layer.
@onready var GAME_LAYER:Node2D = $Game ## This Node2D acts as a place to store game objects, so that your UI and game objects are seperated.

@onready var window:Window = get_window() ## Quick Access to the Main Window as a Variable

@onready var camera:Camera2D = $Camera ## This is your camera that the FunkinGame will render to.

#region Utility Functions

func add_UI(node:Node): UI_LAYER.add_child(node) ## Adds your Node to the UI Layer. This will always render above the Game Layer
func remove_UI(node:Node): UI_LAYER.remove_child(node) ## Removes your Node from the UI Layer

func add(node:Node): GAME_LAYER.add_child(node) ## Adds your Node to the Game Layer. This will always render below the UI Layer
func remove(node:Node): GAME_LAYER.remove_child(node) ## Removes your Node from the Game Layer.

## 1 Argument Passable function parameter to quickly loop through every object in the Game Layer
func loop_for_game(fiction:Callable): for node in GAME_LAYER.get_children(): fiction.call(node)
## 1 Argument Passable function parameter to quickly loop through every object in the UI Layer
func loop_for_ui(fiction:Callable): for node in UI_LAYER.get_children(): fiction.call(node)

#endregion

const STARTING_SCENE := preload("res://Funkin/Scenes/MainTesting.tscn")

func _ready():
	instance = self
	# So the camera is always in the center on start-up no matter what
	camera.position = window.size * 0.5
	
	# Initalize starting scene.
	switch_state(STARTING_SCENE)


## Change states from one Scene to another without thinking! Returns false if failed to load or properly initalize the New Scene.
func switch_state(packed:PackedScene)->bool:
	var new_scene:Node = packed.instantiate()
	if !new_scene: return false
	
	# Once we are done with the state, kill everyone and then get the new scene information
	loop_for_game(func(node:Node): node.queue_free())
	loop_for_ui(func(node:Node): node.queue_free())
	
	add(new_scene)
	
	# If the scene has a Layer the same name as our UILayer, then reparent them to this state's UILayer for formality
	var uiLayer:CanvasLayer = new_scene.get_node_or_null('%s' % UI_LAYER.name)
	if uiLayer:
		for node in uiLayer.get_children(): node.reparent(UI_LAYER)
		uiLayer.queue_free()
	
	return true
