extends Node2D

@onready var volumebox:Sprite2D = $Volumebox

@onready var clipRect:Control = $ClipRect
@onready var volume_bar:Sprite2D = $ClipRect/BarVolume

@onready var hide_tray_timer:Timer = $HideTimer

@onready var volume_up:AudioStreamPlayer2D = $VolumeUp
@onready var volume_down:AudioStreamPlayer2D = $VolumeDown
@onready var volume_max:AudioStreamPlayer2D = $VolumeMAX

func _ready()->void:
	hideTray()
	hide_tray_timer.timeout.connect(hideTray)
	target_volume = -30
	clipRect.clip_contents = true;

var lerp_time:float = 0

var master = AudioServer.get_bus_index("Master")
var master_volume:float:
	get(): return AudioServer.get_bus_volume_db(master)

const MIN_VOLUME:float = -80.0
const MAX_VOLUME:float = 6.0

var target_volume:float = MIN_VOLUME:
	set(amount):
		lerp_time = 0
		target_volume = clamp(amount, MIN_VOLUME, MAX_VOLUME)

var mute:bool = false:
	set(value):
		AudioServer.set_bus_volume_db(master, MIN_VOLUME if value else target_volume)
		mute = value
		update_ui()

func _process(delta: float) -> void:
	
	check_inputs()
	
	if lerp_time < 1: lerp_time += delta*0.5
	else: return
	
	var new_volume:float = lerp(master_volume, target_volume, clamp(lerp_time, 0, 1))
	if new_volume != target_volume and !mute: AudioServer.set_bus_volume_db(master, new_volume)
	
	update_ui()

func update_ui():
	if mute: volume_bar.modulate.a = 0.5
	else: volume_bar.modulate.a = 1
	
	var display_volume = master_volume if !mute else target_volume
	
	var size:Vector2 = volume_bar.texture.get_size()
	clipRect.position.x = -size.x * 0.5
	clipRect.position.y = -size.y
	clipRect.size.x = lerpf(0, size.x, 1 - display_volume/MIN_VOLUME)
	clipRect.size.y = size.y

func check_inputs()->void:
	
	if Input.is_action_just_pressed("volume_mute"):
		mute = !mute
		showTray()
		return
	
	var value:int = 0
	if Input.is_action_just_pressed("volume_down"):
		volume_up.play()
		value = -1
	elif Input.is_action_just_pressed("volume_up"):
		volume_down.play()
		value = 1
	
	if Input.is_key_pressed(KEY_SHIFT): value *= 4
	
	if value == 0: return
	
	target_volume += value*2
	showTray()

func showTray()->void:
	var tweenIn:Tween = get_tree().create_tween()
	tweenIn.tween_property(self, "position:y", 90, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	hide_tray_timer.start(2)

func hideTray()->void:
	var tweenOut:Tween = get_tree().create_tween()
	tweenOut.tween_property(self, "position:y", -150, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
