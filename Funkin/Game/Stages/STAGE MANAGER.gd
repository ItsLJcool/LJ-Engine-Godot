class_name StageManager extends Node

const BACKUP_STAGE:PackedScene = preload("res://Funkin/Game/Stages/BackupStage.tscn")
const STAGES_PATH:String = "res://Funkin/Game/Stages/%s.tscn"

@onready var starting_camera_marker:Marker2D = $CameraStartPos

@onready var character_positions:Node = $CharacterPositions

@onready var layer_behind:Node = $Behind
@onready var layer_characters:Node = $Characters
@onready var layer_front:Node = $Front

func add_character(char:Character): layer_characters.add_child(char)

func loop_for_node(item:Node, fiction:Callable): for node:Node in item.get_children(): fiction.call(node)
func reparent_children_to(new_parent:Node, children:Node, path:String = "%s"):
	var container:Node = children.get_node_or_null(path % new_parent.name)
	if container is Node:
		for node in container.get_children(): node.reparent(new_parent)
		container.queue_free()
func set_node_to(default:Node, check_node:Node, path:String = "%s")->Node:
	var container:Node = check_node.get_node_or_null(path % default.name)
	return container if container is Node else default

func clear_stage(remove_characters:bool = false):
	var free:Callable = func(node:Node): node.queue_free()
	loop_for_node(layer_behind, free)
	if remove_characters: loop_for_node(layer_characters, free)
	loop_for_node(layer_front, free)
	loop_for_node(character_positions, free)

func load_stage(local_name_path:String = ""):
	
	var stage_path:String = STAGES_PATH % local_name_path
	var stage:Node = load(stage_path).instantiate() if ResourceLoader.exists(stage_path) else BACKUP_STAGE.instantiate()

	if !stage:
		printerr("Failed to instantiate %s Stage" % local_name_path)
		return
	
	clear_stage()
	
	starting_camera_marker = set_node_to(starting_camera_marker, stage)
	for node:Node in [character_positions, layer_behind, layer_characters, layer_front]: reparent_children_to(node, stage)
	
	
