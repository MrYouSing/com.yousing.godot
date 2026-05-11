## A wrapper class for [CollisionObject2D] and [CollisionObject3D].
class_name Collider extends Node

@export_group("Collider")
@export var enabled:bool=true
@export var node:Node
@export var process:bool
@export_flags_3d_physics var layer:int
@export_flags_3d_physics var mask:int

func set_node(n:Node,b:bool)->void:
	if n==null:
		pass
	elif b:
		if layer!=0:n.set(&"collision_layer",layer)
		if mask!=0:n.set(&"collision_mask",mask)
		if process:n.process_mode=PROCESS_MODE_INHERIT
	else:
		if process:n.process_mode=Node.PROCESS_MODE_DISABLED
		if layer!=0:n.set(&"collision_layer",0)
		if mask!=0:n.set(&"collision_mask",0)

func set_enabled(b:bool)->void:
	if b==enabled:return
	enabled=b
	if not is_node_ready():return
	set_node(node,b)

func _ready()->void:
	var b:bool=enabled
	enabled=not b
	set_enabled(b)
