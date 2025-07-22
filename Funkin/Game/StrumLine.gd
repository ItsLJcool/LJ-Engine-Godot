@tool
## Container of your Strum class and extra information with it.
class_name StrumLine extends Node2D

#region Init Variables

@onready var strumsGroup:Node2D = $Strums ## Node2D that contains your Strum instances. Wow so cool at not using arrays!!

const MAX_STRUMS:int = 4 ## Maximum Value of your Strums in a container, somewhat of a Multikey support.

# also yes I know it should be 0.25 is left and 0.75 is right but I suck at math. pls fix later
## Idea taken from CodenameEngine. 0.025 is Left. 0.975 is Right. 0 and 1 toutch the edge of the window.
@export_range(0, 1) var StrumLinePos:float = 0.025:
	set(value):
		StrumLinePos = value
		refresh_strums(false)

@export_range(1, MAX_STRUMS+1) var StrumsAmount:int = 4: ## Your Strum Count. Somewhat of a Multikey Support. DOESN'T WORK RIGHT NOW!!
	set(value):
		if (value > MAX_STRUMS): value = MAX_STRUMS
		StrumsAmount = value
		refresh_strums()

@export var padding:float = 112: ## Padding between each Strum
	set(value):
		padding = value
		refresh_strums(false)

## Blueprint to spawn new strums
const strum_blueprint := preload("res://Funkin/Game/Strum.tscn")

## If the player's input should be on this strumline, or if the CPU should be hitting the notes.
@export var isPlayer:bool = false

#endregion

func _ready()->void:
	refresh_strums(true)
	self.position.y = 75

## Adds a note and initalizes it into the Corresponding Strum Direction
func add_note(dir:Strum.NoteDirection, time:float, susLength:float)->void:
	var strum:Strum = strumsGroup.get_children()[dir]
	if !strum: return
	strum.preload_note(time, susLength)

func _process(_delta: float) -> void:
	
	if isPlayer:
		loop_for_strums(func(strum:Strum): strum.on_input() )
	

func refresh_strums(_queue_free:bool = false)->void: ## Re-evaluates positional data, and if needed to, destroy's the strums and reinitalizes them.
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

func loop_for_strums(fiction:Callable) -> void: ## Basic Util for looping through each Strum
	for i:Strum in strumsGroup.get_children():
		if !i is Strum: continue
		fiction.call(i)
