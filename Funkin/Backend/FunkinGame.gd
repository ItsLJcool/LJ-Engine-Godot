# Ok this class is basically inspired from Flixel, but trust me I think it will be good to have this here.
# We can make Custom Loading Screens, UI Elements, Utilities, etc.
class_name FunkinGame extends Node

signal on_game_ready()

static var instance:FunkinGame ## Access to the only instance of FunkinGame

static var window:Window ## Quick Access to the Main Window as a Variable

#region Layers
@onready var __UI_LAYER:CanvasLayer = $UILayer ## Internal variable to be referenced by static
static var UI_LAYER:CanvasLayer: ## This will be your UI Layer. Moving the camera will not affect objects on this layer.
	get: return instance.__UI_LAYER
	set(value): return

@onready var __ui_control:Control = $"UILayer/UI Control"
static var UI_CONTROL:Control:
	get: return instance.__ui_control
	set(value): return

@onready var __STATIC_GAME_LAYER:Node2D = $"Static Game" ## Internal variable to be referenced by static
static var STATIC_GAME_LAYER:Node2D: ##
	get: return instance.__STATIC_GAME_LAYER
	set(value): return

@onready var __GAME_LAYER:Node2D = $Game ## Internal variable to be referenced by static
static var GAME_LAYER:Node2D: ## This Node2D acts as a place to store game objects, so that your UI and game objects are seperated.
	get: return instance.__GAME_LAYER
	set(value): return

@onready var __INFORMATION_LAYER:CanvasLayer = $Information
static var INFORMATION_LAYER:CanvasLayer:
	get: return instance.__INFORMATION_LAYER
	set(value): return

@onready var __CAMERA_FOCUS:Marker2D = $CameraFocus
static var CAMERA_FOCUS:Marker2D:
	get: return instance.__CAMERA_FOCUS
	set(value): return

#endregion

#region Usefull variables
@onready var __camera:FunkinCamera = $FunkinCamera 
static var camera:FunkinCamera: ## This is your camera that the FunkinGame will render to.
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

#endregion

#region Utility Functions

static func static_add(node:Node): STATIC_GAME_LAYER.add_child(node) ## Adds your Node to the Static Game Layer. This will never be automatically cleared.
static func static_remove(node:Node): STATIC_GAME_LAYER.remove_child(node)  ## Removes your Node from the Static Game Layer.

## 1 Argument Passable function parameter to quickly loop through every object in the Static Game Layer
static func loop_for_static_game(fiction:Callable): for node:Node in STATIC_GAME_LAYER.get_children(): fiction.call(node)
static func clear_static_game(): loop_for_static_game(func(node:Node): node.queue_free())

static func add(node:Node): GAME_LAYER.add_child(node) ## Adds your Node to the Game Layer. This will always render below the UI Layer
static func remove(node:Node): GAME_LAYER.remove_child(node) ## Removes your Node from the Game Layer.

## 1 Argument Passable function parameter to quickly loop through every object in the Game Layer
static func loop_for_game(fiction:Callable): for node:Node in GAME_LAYER.get_children(): fiction.call(node)


static func add_UI(node:Node): UI_LAYER.add_child(node) ## Adds your Node to the UI Layer. This will always render above the Game Layer
static func remove_UI(node:Node): UI_LAYER.remove_child(node) ## Removes your Node from the UI Layer

## 1 Argument Passable function parameter to quickly loop through every object in the UI Layer
static func loop_for_ui(fiction:Callable): for node:Node in UI_CONTROL.get_children(): fiction.call(node)


static func reset_camera_position():
	CAMERA_FOCUS.position = Vector2.ZERO
	camera.follow(CAMERA_FOCUS)
	camera.snap_to_focus()
	camera.zoom_val = 1
	camera.snap_zoom()

#endregion

static var DEFAULT_WINDOW_SIZE:Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width", 1280), ProjectSettings.get_setting("display/window/size/viewport_height", 720))

var STARTING_SCENE:String = ProjectSettings.get_setting("application/run/funkin_main_scene", "res://Funkin/Backend/Internal/BackupScene.tscn")
var color:Color = ProjectSettings.get_setting("engine/default_bg_color", Color.BLACK)

func _ready():
	if instance != null:
		queue_free()
		return
	
	instance = self
	window = get_window()
	
	RenderingServer.set_default_clear_color(color)
	
	var disable_physics = (func(node:Node): node.set_physics_process(false) )
	disable_physics.call(self)
	call_all_function(self, disable_physics)
	get_tree().node_added.connect(disable_physics)
	
	SoundTray.position.x = window.size.x * 0.5
	SoundTray.position.y = -100
	
	on_game_ready.emit()
	call_all_method(self, "game_ready")
	
	reset_camera_position()
	# Initalize starting scene.
	switch_state(load(STARTING_SCENE), true, true)

func call_all_method(node:Node, method_name:String):
	for child in node.get_children():
		if child.has_method(method_name): child.call(method_name)
		call_all_method(child, method_name)

func call_all_function(node:Node, fiction:Callable):
	for child:Node in node.get_children():
		fiction.call(child)
		call_all_function(child, fiction)

## Change states from one Scene to another without thinking! Returns false if failed to load or properly initalize the New Scene.
static func switch_state(packed:PackedScene, skip_in:bool = false, skip_out:bool = false)->bool:
	var new_scene:Node = packed.instantiate()
	if !new_scene: return false
	
	new_scene.set_process(false)
	
	if !skip_in:
		TransitionNode.do_transition(false)
		await TransitionNode.transition_complete
	else: TransitionNode.prepare_transition(true)
	
	camera.do_bumping = false
	reset_camera_position()
	
	# Once we are done with the state, kill everyone and then get the new scene information
	loop_for_game(func(node:Node): node.queue_free()) # /kill @e[type="Game:Node2D"]
	loop_for_ui(func(node:Node): node.queue_free()) # /kill @e[type="UILayer:Node2D"]
	
	add(new_scene)
	
	# If the scene has a Layer the same name as our UILayer, then reparent them to this state's UILayer for formality
	var uiLayer:CanvasLayer = new_scene.get_node_or_null('%s' % UI_LAYER.name)
	if uiLayer is CanvasLayer:
		for node in uiLayer.get_children(): node.reparent(UI_CONTROL)
		uiLayer.queue_free()
	
	if !skip_out:
		TransitionNode.do_transition(true)
		await TransitionNode.transition_complete
	else: TransitionNode.prepare_transition(false)
	
	new_scene.set_process(true)
	
	if new_scene.has_method("scene_ready"): new_scene.call("scene_ready")
	return true
