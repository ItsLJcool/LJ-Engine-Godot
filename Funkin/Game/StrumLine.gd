@tool
## Container of your Strum class and extra information with it.
class_name StrumLine extends Node2D
#region Init Variables

@onready var strumsGroup:Node2D = $Strums

## Maximum Value of your Strums in a container, somewhat of a Multikey support.
const MAX_STRUMS:int = 4

## Idea taken from CodenameEngine. 0.025 is Left. 0.975 is Right. 0 and 1 toutch the edge of the window.
@export_range(0, 1) var StrumLinePos:float = 0.025:
	set(value):
		StrumLinePos = value
		update_strums(false)

@export_range(1, MAX_STRUMS+1) var StrumsAmount:int = 4:
	set(value):
		if (value > MAX_STRUMS): value = MAX_STRUMS
		StrumsAmount = value
		update_strums()

@export var padding:float = 112:
	set(value):
		padding = value
		update_strums(false)

## Blueprint to spawn new strums
const strum_blueprint = preload("res://Funkin/Game/Strum.tscn")

## If the player's input should be on this strumline, or if the CPU should be hitting the notes.
@export var isPlayer:bool = false

#endregion

func _ready()->void:
	print()
	update_strums(true) # just in case ig
	self.position.y = 75

func add_note(directon:Strum.NoteDirection, time:float, susLength:float)->void:
	var strum:Strum = strumsGroup.get_children()[directon]
	if !strum: return
	strum.spawn_note(time, susLength)

func _process(_delta: float) -> void:
	
	loop_for_strums(func(strum:Strum): 
		strum.notePath.visible = self.get_meta("render_paths", false)
		strum.notePath.self_modulate.a = self.get_meta("paths_opacity", 1)
	)
	
	if isPlayer:
		for strum in strumsGroup.get_children():
			if !strum is Strum: continue
			strum.on_input()
	

func update_strums(_queue_free:bool = false)->void:
	if !strumsGroup: return
	if _queue_free:
		for i in strumsGroup.get_children(): i.queue_free()
		for idx in range(0, StrumsAmount):
			var strum = strum_blueprint.instantiate()
			strum.name = str(idx)
			strum.strumLine = self
			strum.direction = idx
			strumsGroup.add_child(strum)
			strum.init()
	
	var total = strumsGroup.get_children().size()
	var offset = (padding * total) * 0.5
	
	# 1280 needs to be the width of the window. Hardcoded for now
	self.global_position.x = lerpf(offset, (1280 - offset), StrumLinePos)
	for i in strumsGroup.get_children(): i.position.x = (((padding) * i.direction) + (padding * 0.5)) - offset

func loop_for_strums(fiction:Callable) -> void:
	for i in strumsGroup.get_children():
		if !i is Strum: continue
		fiction.call(i)
