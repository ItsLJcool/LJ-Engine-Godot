class_name MultiAudioStreamPlayer extends AudioStreamPlayer

# too lazy to finish LMAO

var players:Array[AudioStreamPlayer] = [self]

func _init(...args:Array) -> void:
	for value:String in args:
		pass
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('hi')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
