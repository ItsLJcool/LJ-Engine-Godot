extends Node2D

@onready var character:Character = $Character
@onready var ghost_character:Character = $Character

func _ready() -> void:
	ghost_character.visible = true
	ghost_character.modulate.a = 0.5
