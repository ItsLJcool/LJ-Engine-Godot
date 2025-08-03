class_name StageManager extends Node

enum StagePosition {
	DAD = 0,
	BF = 1,
	GF = 2,
	OTHER = 3
}
static func stage_pos_to_string(type:StagePosition)->String: return StagePosition.keys()[type].to_lower()

const BACKUP_STAGE:PackedScene = preload("res://Funkin/Game/Stages/BackupStage.tscn")
const STAGES_PATH:String = "res://Funkin/Game/Stages/%s.tscn"

@onready var starting_camera:Camera2D = $StartingCamera

@onready var character_positions:Node = $CharacterPositions

@onready var layer_behind:Node = $Behind
@onready var layer_characters:Node = $Characters
@onready var layer_front:Node = $Front

func add_character(character:Character, type:StagePosition = StagePosition.BF):
	layer_characters.add_child(character)
	position_character(character, type)

func position_character(character:Character, type:StagePosition = StagePosition.OTHER):
	for pos:Marker2D in character_positions.get_children():
		if pos is not Marker2D: continue
		var marker_name:String = pos.name.to_lower()
		var type_name:String = stage_pos_to_string(type)
		if marker_name != type_name: continue
		character.position = pos.position

func loop_for_node(item:Node, fiction:Callable): for node:Node in item.get_children(): fiction.call(node)

func reparent_children_to(new_parent:Node, children:Node, path:String = "%s"):
	var container:Node = children.get_node_or_null(path % new_parent.name)
	if container:
		for node in container.get_children(): node.reparent(new_parent)
		container.queue_free()

func set_node_to(default:Node, check_node:Node, path:String = "%s")->Node:
	var container:Node = check_node.get_node_or_null(path % default.name)
	print(container)
	if container:
		default.queue_free()
		return container
	return default

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
	
	add_child(stage)
	
	starting_camera = set_node_to(starting_camera, stage)
	for node:Node in [character_positions, layer_behind, layer_characters, layer_front]: reparent_children_to(node, stage)
	
