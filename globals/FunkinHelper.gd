class_name FunkinHelper extends Node

## When initalizing a new remap, your parameters should be in order of
## [member ARROW], [member PRESS], [member CONFIRM], [member HOLD], [member END],
## [member LEFT], [member DOWN], [member UP], [member RIGHT].[br][br]
## If you pass in [b][operator false][/b] in any parameter it will retain it's default value.
class FunkinAnimationRemap:
	static var remaps:Dictionary[StringName, FunkinAnimationRemap] = {
		&"default": FunkinAnimationRemap.new()
	}
	
	var ARROW:StringName = &"arrow"
	
	var PRESS:StringName = &"press"
	var CONFIRM:StringName = &"confirm"
	
	var HOLD:StringName = &"hold piece"
	var END:StringName = &"hold end"
	
	var LEFT:StringName = &"left"
	var DOWN:StringName = &"down"
	var UP:StringName = &"up"
	var RIGHT:StringName = &"right"
	
	func _helper(setter:StringName, values:Array[StringName]) -> StringName:
		if values.size() <= 0: return setter
		
		var value = values.pop_front()
		# If the value is truthy (so if it's false or null it will not return value)
		if value: return value
		
		return setter
	
	## Hi this is to force show this in the docs
	func _init(...args:Array):
		if args.size() <= 0: return
		self.ARROW = _helper(self.ARROW, args)
		self.PRESS = _helper(self.PRESS, args)
		self.CONFIRM = _helper(self.CONFIRM, args)
		
		self.HOLD = _helper(self.HOLD, args)
		self.END = _helper(self.END, args)
		
		self.LEFT = _helper(self.LEFT, args)
		self.DOWN = _helper(self.DOWN, args)
		self.UP = _helper(self.UP, args)
		self.RIGHT = _helper(self.RIGHT, args)


enum DirectionType {
	LEFT = 0,
	DOWN = 1,
	UP = 2,
	RIGHT = 3
}

static func get_remap(type:StringName) -> FunkinAnimationRemap:
	if not FunkinAnimationRemap.remaps.has(type): FunkinAnimationRemap.remaps.get(&"default")
	return FunkinAnimationRemap.remaps.get(type)

static func add_remap(type:StringName) -> FunkinAnimationRemap:
	if FunkinAnimationRemap.remaps.has(type):
		push_warning("Attempted to add a remap that already exists.")
		return FunkinAnimationRemap.remaps.get(type)
	
	var funk_remap:FunkinAnimationRemap = FunkinAnimationRemap.new()
	FunkinAnimationRemap.remaps.set(type, funk_remap)
	return funk_remap

static func direction_to_nametype(dir:DirectionType, type:StringName) -> StringName:
	match dir:
		DirectionType.DOWN: return get_remap(type).DOWN
		DirectionType.UP: return get_remap(type).UP
		DirectionType.RIGHT: return get_remap(type).RIGHT
		_: return get_remap(type).LEFT
