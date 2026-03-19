## A wrapper class for [CollisionObject2D] and [CollisionObject3D].
class_name Collider extends Node

@export_group("Collider")
@export var enabled:bool=true
@export var node:Node
@export_flags_3d_physics var layer:int
@export_flags_3d_physics var mask:int

func set_node(n:Node,b:bool)->void:
	if n==null:
		pass
	elif b:
		n.set(&"collision_layer",layer)
		n.set(&"collision_mask",mask)
	else:
		n.set(&"collision_layer",0)
		n.set(&"collision_mask",0)

func set_enabled(b:bool)->void:
	if b==enabled:return
	enabled=b
	if not is_node_ready():return
	set_node(node,b)

func _ready()->void:
	var b:bool=enabled
	enabled=not b
	set_enabled(b)
