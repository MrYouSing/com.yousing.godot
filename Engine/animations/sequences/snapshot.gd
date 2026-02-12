## A snapshot which captures objects at one frame.
class_name Snapshot extends Resource

@export_group("Snapshot")
@export var paths:Array[NodePath]
@export var names:Array[StringName]
@export var floats:Array[float]
@export var variants:Array[Variant]
@export var samples:Dictionary[StringName,float]

func save(n:Node)->void:
	if n==null:return
	var it:Node=n;var b:int=paths.size();var c:int=names.size()
	var p:NodePath;var v:Variant
	if floats.size()<c:floats.resize(c);variants.resize(c)
	for i in c:
		if i<b:p=paths[i];if not p.is_empty():it=n.get_node_or_null(p)
		if it!=null:
			v=it.get(names[i]);match typeof(v):
				TYPE_NIL:floats[i]=NAN;variants[i]=null
				TYPE_FLOAT:floats[i]=v;variants[i]=null
				_:variants[i]=v;floats[i]=NAN

func load(n:Node)->void:
	if n==null:return
	var it:Node=n;var b:int=paths.size();var c:int=names.size()
	var p:NodePath;var f:float
	for i in c:
		if i<b:p=paths[i];if not p.is_empty():it=n.get_node_or_null(p)
		if it!=null:
			f=floats[i]
			if not is_nan(f):it.set(names[i],f)
			else:it.set(names[i],variants[i])
