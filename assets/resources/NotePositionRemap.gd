class_name NotePositionRemap

static func normal(time:float, speed_mult:float) -> float: return ( (time - Conductor.song_position) * speed_mult )
