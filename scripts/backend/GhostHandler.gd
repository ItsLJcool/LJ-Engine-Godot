class_name GhostHandler extends Node

var node:AnimatedSprite2D

func _init(spr:AnimatedSprite2D):
	node = spr
	node.z_index = -1
	node.modulate.a = 0.5
	add_child(node)
