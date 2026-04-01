## A snapshot which captures objects at one frame.
class_name Snapshot extends Resource

@export_group("Snapshot")
@export var paths:Array[NodePath]
@export var names:Array[StringName]
@export var variants:Array
@export var samples:Dictionary[StringName,float]

func save(n:Node)->void:
	if n==null:return
	var it:Node=n;var b:int=paths.size();var c:int=names.size()
	var p:NodePath;if variants.size()!=c:variants.resize(c)
	for i in c:
		if i<b:p=paths[i];if not p.is_empty():it=n.get_node_or_null(p)
		if it!=null:variants[i]=it.get(names[i])

func load(n:Node)->void:
	if n==null:return
	var it:Node=n;var b:int=paths.size();var c:int=names.size()
	var p:NodePath
	for i in c:
		if i<b:p=paths[i];if not p.is_empty():it=n.get_node_or_null(p)
		if it!=null:it.set(names[i],variants[i])
