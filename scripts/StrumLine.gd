class_name StrumLine extends Node2D

var strums_group:Node2D = Node2D.new()

var key_count:int = 4
var scale_factor:float = 1
var position_offset:Vector2 = Vector2.ZERO

## Temporary variable
var cpu:bool = true:
	set(v):
		cpu = v
		for strum:Strum in strums_group.get_children(): strum.cpu = v

var hud_pos:float = 0.5:
	set(v):
		hud_pos = v
		position.x = ProjectSettings.get_setting("display/window/size/viewport_width") * v


var scroll_speed:float = 1.5:
	set(v):
		scroll_speed = v
		for strum:Strum in strums_group.get_children(): strum.scroll_speed = v

var type:StringName = &"default"
var remap_type:FunkinHelper.FunkinAnimationRemap:
	get: return FunkinHelper.get_remap(self.type)

func regen_strums():
	for strum:Node in strums_group.get_children(): strums_group.remove_child(strum)
	
	for idx in range(key_count):
		var strum:Strum = Strum.new((idx as FunkinHelper.DirectionType), type)
		strum.scale = Vector2(scale_factor, scale_factor)
		strum.position.x = (position_offset.x * idx)
		strum.position.x -= position_offset.x * ((key_count-1)*0.5)
		strum.position.y += position_offset.y
		strums_group.add_child(strum)

func _init(data:ChartStrumLine = ChartStrumLine.new()) -> void:
	key_count = data.key_count
	scale_factor = data.scale
	position_offset = Vector2(160 * scale_factor, 100)
	
	add_child(strums_group)
	
	regen_strums()
	
	scroll_speed = data.scroll_speed
	for strum:Strum in strums_group.get_children():
		strum.preload_notes(data.filter_direction(strum.dir))
	
	hud_pos = hud_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
