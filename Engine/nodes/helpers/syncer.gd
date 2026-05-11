## A helper class for property synchronization.
class_name Syncer extends Updatable

@export_group("Source","src_")
@export var src_node:Node
@export var src_name:StringName
@export_group("Destination","dst_")
@export var dst_node:Node
@export var dst_name:StringName

func run()->void:
	if src_node!=null and dst_node!=null:
		dst_node.set(dst_name,src_node.get(src_name))
