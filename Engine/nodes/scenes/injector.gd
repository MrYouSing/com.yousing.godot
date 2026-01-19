## A helper class that injects objects at runtime.
class_name Injector extends Node

@export_group("Injector")
@export var auto:bool=true
@export_enum("Property","Signal","Global","Event")
var types:Array[int]
@export_group("Source","src_")
@export var src_resources:Array[Resource]
@export var src_nodes:Array[Node]
@export var src_paths:Array[StringName]
@export var src_keys:Array[StringName]
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
	var c:int=src_nodes.size()
	if a>0:
		if b>0:for i in a:
			inject_object(types[i],find_resource(src_resources[i],src_paths[i]),src_keys[i],find_resource(dst_resources[i],dst_paths[i]),dst_keys[i])
		else:for i in a:
			inject_object(types[i],find_resource(src_resources[i],src_paths[i]),src_keys[i],find_node(dst_nodes[i],dst_paths[i]),dst_keys[i])
	else:
		a=c
		if b>0:for i in a:
			inject_object(types[i],find_node(src_nodes[i],src_paths[i]),src_keys[i],find_resource(dst_resources[i],dst_paths[i]),dst_keys[i])
		else:for i in a:
			inject_object(types[i],find_node(src_nodes[i],src_paths[i]),src_keys[i],find_node(dst_nodes[i],dst_paths[i]),dst_keys[i])

func find_script(o:Object)->Script:
	if o!=null:
		if o is Script:return o
		else:return o.get_script()
	return null

func find_resource(r:Resource,k:StringName)->Resource:
	if r==null and FileAccess.file_exists(k):r=load(k)
	return r

func find_node(n:Node,k:StringName)->Node:
	var c:Node=null
	if n!=null:
		if k.is_empty():
			c=n
		else:
			if n is Actor:c=n.get_component(k)
			if c==null:c=n.get_node_or_null(NodePath(k))
	return c

func inject_object(t:int,s:Object,i:StringName,d:Object,j:StringName)->void:
	if s!=null:src_obj=s
	if d!=null:dst_obj=d
	#
	if src_obj!=null and dst_obj!=null:
		match t:
			0:dst_obj.set(j,src_obj if i.is_empty() else src_obj.get(i))
			1:src_obj.connect(i,Callable(dst_obj,j))
			2:
				var g:Script=find_script(dst_obj)
				if g!=null:g.set(j,src_obj if i.is_empty() else src_obj.get(i))
			3:
				var g:Script=find_script(src_obj)
				if g!=null:g.connect(i,Callable(dst_obj,j))
	else:
		src_obj=null;dst_obj=null
