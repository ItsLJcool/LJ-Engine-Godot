@tool
extends Node

var character_positions:Array[Marker2D] = []
var characters:Array[Character] = []
func _ready() -> void:
	if !Engine.is_editor_hint():
		set_process(false)
		return
	
	reset_positions()

func reset_positions():
	for node in characters: node.queue_free()
	character_positions = []
	characters = []
	
	var children:Array[Node] = self.get_children()
	for idx in range(0, children.size()):
		var marker = children[idx]
		if marker is not Marker2D: continue
		
		var char_name:String = char_names[idx] if idx < char_names.size() else "bf"
		var character = Character.create(char_name)
		
		character_positions.push_back(marker)
		characters.push_back(character)
		add_child(character)
	

@export_tool_button("Reload Characters") var _reset = reset_positions

@export var char_names:Array[String] = []

func _process(delta: float) -> void:
	for idx in range(0, character_positions.size()):
		var marker = character_positions[idx]
		var char = characters[idx]
		if !marker or !char: continue
		char.position = marker.position
