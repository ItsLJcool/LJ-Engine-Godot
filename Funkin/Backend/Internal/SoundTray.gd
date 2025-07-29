class_name BaseSoundTray extends Node2D

@onready var volumebox:Sprite2D = $Volumebox

@onready var clipRect:Control = $ClipRect
@onready var volume_bar:Sprite2D = $ClipRect/BarVolume
@onready var volume_bar_behind:Sprite2D = $ClipRect/BarVolume_Behind

@onready var hide_tray_timer:Timer = $HideTimer

@onready var volume_up:AudioStreamPlayer2D = $VolumeUp
@onready var volume_down:AudioStreamPlayer2D = $VolumeDown
@onready var volume_max:AudioStreamPlayer2D = $VolumeMAX

static var instance:BaseSoundTray

## If the SoundTray should be using any value from MIN_VOLUME to MAX_VOLIME, or it should be bound by Steps
static var USE_FLOAT_PRECISION:bool = false: 
	set(value):
		USE_FLOAT_PRECISION = value
		if !instance.volume_bar_behind or !instance.volume_bar: return
		instance.volume_bar.visible = true
		if USE_FLOAT_PRECISION: instance.volume_bar_behind.visible = false
		else:
			instance.volume_bar_behind.visible = true
			instance.volume_bar_behind.self_modulate.a = 0.5

static var STEP_MAX:int = 10
var current_step:int = floori(STEP_MAX * 0.5)+1:
	set(value):
		current_step = clamp(value, 0, STEP_MAX)
		if USE_FLOAT_PRECISION: return
		master_volume = lerpf(MIN_VOLUME, MAX_VOLUME, float(current_step)/STEP_MAX)
		if !instance.volume_bar.visible: return
		if current_step == 0:
			mute = true
			return
		else:
			mute = false
		instance.volume_bar.texture = load("res://Assets/Images/soundtray/bars_%s.png" % (current_step))

#region Variables

const MIN_VOLUME:float = -80.0
const MAX_VOLUME:float = 6.0

var master = AudioServer.get_bus_index("Master")
var master_volume:float:
	get(): return AudioServer.get_bus_volume_db(master)
	set(value): AudioServer.set_bus_volume_db(master, clamp(value, MIN_VOLUME, MAX_VOLUME))

var target_volume:float = MIN_VOLUME:
	set(amount):
		lerp_time = 0
		target_volume = clamp(amount, MIN_VOLUME, MAX_VOLUME)

var mute:bool = false:
	set(value):
		mute = value
		AudioServer.set_bus_mute(master, mute)
		update_ui()

#endregion

func _ready()->void:
	if instance:
		queue_free()
		return
	instance = self
	
	USE_FLOAT_PRECISION = USE_FLOAT_PRECISION # yes this is stupid, no im too lazy to fix
	
	var max_bars_texture := load("res://Assets/Images/soundtray/bars_10.png")
	volume_bar.texture = max_bars_texture
	volume_bar_behind.texture = max_bars_texture
	
	hideTray()
	hide_tray_timer.timeout.connect(hideTray)
	
	master_volume = lerpf(MIN_VOLUME, MAX_VOLUME, 0.5)
	target_volume = master_volume
	
	clipRect.clip_contents = true;

var lerp_time:float = 0:
	set(value): lerp_time = clamp(value, 0, 1)

func _process(delta: float) -> void:
	check_inputs()
	
	if USE_FLOAT_PRECISION:
		if lerp_time < 1: lerp_time += delta*0.5
		else: return
		
		master_volume = lerp(master_volume, target_volume, lerp_time)
	
	update_ui()

func update_ui():
	
	if mute:
		volume_bar.modulate.a = 0.5 if USE_FLOAT_PRECISION else 0.0
	else: volume_bar.modulate.a = 1
	
	var size:Vector2 = volume_bar.texture.get_size()
	clipRect.position.x = -size.x * 0.5
	clipRect.position.y = -size.y
	clipRect.size.x = lerpf(0, size.x, (1 - master_volume/MIN_VOLUME) if USE_FLOAT_PRECISION else 1.0)
	clipRect.size.y = size.y

func check_inputs()->void:
	
	if Input.is_action_just_pressed("volume_mute"):
		mute = !mute
		showTray()
		return
	
	var value:int = 0
	if Input.is_action_just_pressed("volume_down"): value -= 1
	if Input.is_action_just_pressed("volume_up"): value += 1
	
	if value == 0: return
	
	var is_max:bool = false
	if USE_FLOAT_PRECISION:
		if Input.is_key_pressed(KEY_SHIFT): value *= 4
		is_max = (target_volume >= MAX_VOLUME) and value > 0
		target_volume += value*2
	else:
		is_max = (master_volume >= MAX_VOLUME) and value > 0
		current_step += value
	
	if !is_max:
		@warning_ignore("standalone_ternary")
		(volume_up.play() if value > 0 else volume_down.play())
	else: volume_max.play()
	
	showTray()

func showTray()->void:
	var tweenIn:Tween = get_tree().create_tween()
	tweenIn.tween_property(self, "position:y", 90, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	hide_tray_timer.start(2)

func hideTray()->void:
	var tweenOut:Tween = get_tree().create_tween()
	tweenOut.tween_property(self, "position:y", -150, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
