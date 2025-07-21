class_name Song extends Node

# Probably remake this class

var vocal_player:AudioStreamPlayer = AudioStreamPlayer.new()

var chart:Dictionary = {}

var isReady:bool = false;

static var songsPath:String = &"res://Assets/Songs"

func _ready():
	add_child(vocal_player)
	start()

func play(songName:String):
	isReady = false
	Conductor.reset()
	
	vocal_player.stream = load("%s/%s/song/Voices.ogg" % [songsPath, songName])
	vocal_player.name = "SongPlayer"
	vocal_player.bus = "Music"
	
	Conductor.audio_stream = load("%s/%s/song/Inst.ogg" % [songsPath, songName])
	isReady = true
	
func start():
	if !isReady: return
	
	vocal_player.play()
	Conductor.play();
	
func pause():
	Conductor.pause()

func resume():
	Conductor.resume()


# Chart Parsing
static func codenameParse(songName:String, difficulty:String = "normal", strumLines:Array[StrumLine] = [])->void:
	var filePath = "%s/%s/charts/%s.json" % [songsPath, songName, difficulty]
	if (!FileAccess.file_exists(filePath)):
		print("Path doesn't exist: ", filePath)
		return
	
	var jsonString = FileAccess.open(filePath, FileAccess.READ)
	var json = JSON.parse_string(jsonString.get_as_text())
	if (!json is Dictionary):
		print("Error reading file")
		return
	
	var jsonStrumLine = json.strumLines
	for idx in range(0, strumLines.size()):
		var strumline:StrumLine = strumLines[idx]
		if !strumline: continue
		
		var notes = jsonStrumLine[idx].notes
		if !notes: continue
		
		for note in notes:
			strumline.loop_for_strums(func(strum:Strum):
				if !strum is Strum: return
				if strum.direction != note.id: return
				strum.spawn_note(note.time, note.sLen)
			)
