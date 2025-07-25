## Quick Utility Class for Parsing and Playing Songs.
class_name Song extends Node

var vocal_player:AudioStreamPlayer = AudioStreamPlayer.new() ## Audio Steam for the Vocals

var isReady:bool = false; ## If the Class is ready to play the song.

static var songsPath:String = &"res://Assets/Songs" ## Path for the Songs Folder

func _ready()->void:
	Conductor.song_start.connect(start)
	add_child(vocal_player)

func init(songName:String, difficulty:String = "")->void: ## Initalizes the Vocals and Conductor with your song name
	isReady = false
	Conductor.reset()
	
	vocal_player.stream = load("%s/%s/song/Voices%s.ogg" % [songsPath, songName, difficulty])
	vocal_player.name = "SongPlayer"
	vocal_player.bus = "Music"
	
	Conductor.audio_stream = load("%s/%s/song/Inst%s.ogg" % [songsPath, songName, difficulty])
	isReady = true

func start()->void: ## Starts the song. Somewhat Internal
	if !isReady: return
	
	vocal_player.play()
	Conductor.play();
	
func pause(): ## Pauses the Audio
	Conductor.pause()
	vocal_player.stream_paused = true

func resume(): ## Resumes the Audio
	Conductor.resume()
	vocal_player.stream_paused = false

# Chart Parsing

## Reusable Parsing Json
static func parseJson(songName:String, difficulty:String = "normal")->Dictionary:
	var filePath = "%s/%s/charts/%s.json" % [songsPath, songName, difficulty]
	if (!FileAccess.file_exists(filePath)):
		print("Path doesn't exist: ", filePath)
		return {}
	
	var jsonString = FileAccess.open(filePath, FileAccess.READ)
	var json = JSON.parse_string(jsonString.get_as_text())
	if (!json is Dictionary):
		print("Error reading file")
		return {}
	
	return json

## Parses your CodenameEngine JSON. Returns True if successful
static func codenameParse(songName:String, difficulty:String = "normal", strumLines:Array = [])->bool:
	var json = parseJson(songName, difficulty)
	if json == {}: return false
	
	var jsonStrumLine = json.strumLines
	for idx in range(0, strumLines.size()):
		var strumline = strumLines[idx]
		if !strumline: continue
		strumline.loop_for_strums(func(strum): strum.scrollSpeed = json.scrollSpeed)
		
		var notes = jsonStrumLine[idx].notes
		if !notes: continue
		
		for note in notes:
			strumline.add_note(note.id, note.time, note.sLen)
	
	return true
