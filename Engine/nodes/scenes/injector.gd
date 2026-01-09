## A helper class that injects properties at runtime.
class_name Injector extends Node

@export var auto:bool=true
@export_group("Source","src_")
@export var src_resources:Array[Resource]
@export var src_nodes:Array[Node]
@export var src_paths:Array[StringName]
@export_group("Destination","dst_")
@export var dst_resources:Array[Resource]
@export var dst_nodes:Array[Node]
@export var dst_paths:Array[StringName]
@export var dst_keys:Array[StringName]

var src_obj:Object
var dst_obj:Object

func _ready()->void:
	if auto:inject()

func inject()->void:
	src_obj=null;dst_obj=null
	var a:int=src_resources.size();var b:int=dst_resources.size()
	if a>0:
		if b>0:for i in a:
			inject_object(src_resources[i],dst_resources[i],dst_keys[i])
		else:for i in a:
			inject_object(src_resources[i],find_node(dst_nodes[i],dst_paths[i]),dst_keys[i])
	else:
		a=src_nodes.size()
		if b>0:for i in a:
			inject_object(find_node(src_nodes[i],src_paths[i]),dst_resources[i],dst_keys[i])
		else:for i in a:
			inject_object(find_node(src_nodes[i],src_paths[i]),find_node(dst_nodes[i],dst_paths[i]),dst_keys[i])

func find_node(n:Node,k:StringName)->Node:
	var c:Node=null
	if n!=null:
		if k.is_empty():
			c=n
		else:
			if n is Actor:c=n.get_component(k)
			if c==null:c=n.get_node_or_null(NodePath(k))
	return c

func inject_object(s:Object,d:Object,k:StringName)->void:
	if s!=null:src_obj=s
	if d!=null:dst_obj=d
	#
	if src_obj!=null and dst_obj!=null and !k.is_empty():
		dst_obj.set(k,src_obj)
	else:
		src_obj=null;dst_obj=null
