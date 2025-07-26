# Ok this class is basically inspired from Flixel, but trust me I think it will be good to have this here.
# We can make Custom Loading Screens, UI Elements, Utilities, etc.
class_name FunkinGame extends Node

signal on_game_ready()
signal test

static var instance:FunkinGame ## Access to the only instance of FunkinGame

@onready var __UI_LAYER:CanvasLayer = $UILayer
static var UI_LAYER:CanvasLayer: ## This will be your UI Layer. Moving the camera will not affect objects on this layer.
	get: return instance.__UI_LAYER
	set(value): instance.__UI_LAYER = value

@onready var __GAME_LAYER:Node2D = $Game
static var GAME_LAYER:Node2D: ## This Node2D acts as a place to store game objects, so that your UI and game objects are seperated.
	get: return instance.__GAME_LAYER
	set(value): instance.__GAME_LAYER = value

static var window:Window ## Quick Access to the Main Window as a Variable

@onready var __camera:Camera2D = $Camera 
static var camera:Camera2D: ## This is your camera that the FunkinGame will render to.
	get: return instance.__camera
	set(value): instance.camera = value

@onready var __soundTray:Node2D = $Information/SoundTray
static var SoundTray:Node2D:
	get: return instance.__soundTray
	set(value): instance.__soundTray = value

@onready var __transition:BaseTransition = $Information/BaseTransition
static var TransitionNode:BaseTransition:
	get: return instance.__transition
	set(value): instance.__transition = value

#region Utility Functions

static func add_UI(node:Node): UI_LAYER.add_child(node) ## Adds your Node to the UI Layer. This will always render above the Game Layer
static func remove_UI(node:Node): UI_LAYER.remove_child(node) ## Removes your Node from the UI Layer

static func add(node:Node): GAME_LAYER.add_child(node) ## Adds your Node to the Game Layer. This will always render below the UI Layer
static func remove(node:Node): GAME_LAYER.remove_child(node) ## Removes your Node from the Game Layer.

## 1 Argument Passable function parameter to quickly loop through every object in the Game Layer
static func loop_for_game(fiction:Callable): for node in GAME_LAYER.get_children(): fiction.call(node)
## 1 Argument Passable function parameter to quickly loop through every object in the UI Layer
static func loop_for_ui(fiction:Callable): for node in UI_LAYER.get_children(): fiction.call(node)

#endregion

static var SKIP_TRANS_IN:bool = true
static var SKIP_TRANS_OUT:bool = false

const STARTING_SCENE:PackedScene = preload("res://Funkin/Scenes/MainTesting.tscn")

func _ready():
	window = get_window()
	
	if instance != null:
		queue_free()
		return
	
	instance = self
	# So the camera is always in the center on start-up no matter what
	camera.position = window.size * 0.5
	SoundTray.position.x = window.size.x * 0.5
	SoundTray.position.y = -100
	
	on_game_ready.emit()
	call_all_method(self, "game_ready")
	
	# Initalize starting scene.
	switch_state(STARTING_SCENE)
	

func call_all_method(node:Node, method_name:String):
	for child in node.get_children():
		if child.has_method(method_name): child.call(method_name)
		call_all_method(child, method_name)

## Change states from one Scene to another without thinking! Returns false if failed to load or properly initalize the New Scene.
func switch_state(packed:PackedScene)->bool:
	var new_scene:Node = packed.instantiate()
	if !new_scene: return false
	
	new_scene.set_process(false)
	
	await TransitionNode.transition_in(0 if SKIP_TRANS_IN else 0.5)
	# Once we are done with the state, kill everyone and then get the new scene information
	loop_for_game(func(node:Node): node.queue_free())
	loop_for_ui(func(node:Node): node.queue_free())
	
	add(new_scene)
	
	# If the scene has a Layer the same name as our UILayer, then reparent them to this state's UILayer for formality
	var uiLayer:CanvasLayer = new_scene.get_node_or_null('%s' % UI_LAYER.name)
	if uiLayer is CanvasLayer:
		for node in uiLayer.get_children(): node.reparent(UI_LAYER)
		uiLayer.queue_free()
	
	for i in range(0, 3): await get_tree().process_frame
	
	await TransitionNode.transition_out(0 if SKIP_TRANS_OUT else 0.5)
	
	new_scene.set_process(true)
	
	SKIP_TRANS_IN = false
	SKIP_TRANS_OUT = false
	return true
