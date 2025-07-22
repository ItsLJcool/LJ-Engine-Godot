extends CanvasLayer

@onready var timer = $Timer
@onready var volumeTray = $Panel
@onready var volume_bar = $Panel/Volume  # ProgressBar for volume display

var visible_time = 2.0  # Time before hiding the tray
var hidden_x = 1500     # Off-screen position; adjust as needed
var visible_x = 800     # On-screen position; adjust as needed

var target_volume: float = 0.0  # Target volume (used for lerp)

func _ready():
	volumeTray.position.x = hidden_x  # Start off-screen
	target_volume = get_volume()
	volume_bar.value = db_to_linear(target_volume) * 100  # Sync with current volume
	update_volume_bar(target_volume)

func change_volume(amount: float):
	var bus = AudioServer.get_bus_index("Master")
	target_volume = clamp(target_volume + float(amount), -30.0, 0.0)  # Ensure it's a float
	
	show_tray()  # Show tray whenever volume is changed

	# Start lerping the volume in `_process`
	set_process(true)

func _process(delta):
	var bus = AudioServer.get_bus_index("Master")
	var current_volume: float = AudioServer.get_bus_volume_db(bus)  # Ensure it's a float

	# Lerp towards target volume
	var new_volume: float = lerp(current_volume, target_volume, 5.0 * delta)  # Now both are floats
	
	# Apply new volume if it's close to the target, stop processing
	if abs(new_volume - target_volume) < 0.1:
		new_volume = target_volume
		#set_process(false)  # Stop running _process when done

	AudioServer.set_bus_volume_db(bus, new_volume)
	update_volume_bar(new_volume)
	if Input.is_action_pressed("vol_up"):
		change_volume(0.2)
	elif Input.is_action_pressed("vol_down"):
		change_volume(-0.2)

func update_volume_bar(volume: float):
	volume_bar.value = db_to_linear(volume) * 100.0  # Convert dB to percentage (0-100)

	# If the volume is over the limit, make the bar red
	if volume_bar.value >= volume_bar.max_value:
		var tween = get_tree().create_tween().tween_property(volume_bar, "modulate", Color(1, 0, 0), 0.25)
	else:
		get_tree().create_tween().tween_property(volume_bar, "modulate", Color(1, 1, 1), 0.25)

func show_tray():
	var tween_in = get_tree().create_tween()
	tween_in.tween_property(volumeTray, "position:x", visible_x, 0.25)
	timer.start(visible_time)  # Restart timer to hide tray after a while

func _on_timer_timeout() -> void:
	var tween_out = get_tree().create_tween()
	tween_out.tween_property(volumeTray, "position:x", hidden_x, 0.45)

func get_volume() -> float:
	var bus = AudioServer.get_bus_index("Master")
	return float(AudioServer.get_bus_volume_db(bus))  # Ensure it's a float
