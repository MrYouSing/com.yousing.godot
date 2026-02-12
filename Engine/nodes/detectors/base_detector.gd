## A base class for scene queries.
class_name BaseDetector extends Node

@export_group("Detection")
@export var root:Node
@export var forward:Vector3=Vector3.MODEL_FRONT
@export_flags_3d_physics var mask:int=1
@export var flags:int=-1
@export var exclusion:Array[Node]

var target:Object
var targets:Array[Object]
var infos:Dictionary[RID,Physics.HitInfo]
var dirty:bool=true
var exclude:Array[RID]

func _on_dirty()->void:
	dirty=false
	#
	exclude.clear();
	for it in exclusion:
		if it!=null and it.has_method(&"get_rid"):exclude.append(it.get_rid())
	#
	var i:int=0;var m:int=targets.size();
	var it:Object;while i<m:
		it=targets[i];if it!=null and exclude.has(it.get_rid()):
			targets.remove_at(i);--i;--m
		++i

func _on_find_hit(d:Dictionary)->void:
	if not d.is_empty():
		apply(Physics.HitInfo.from_dict(d))
		_on_find(d.collider)

func _on_miss_hit(d:Dictionary)->void:
	if not d.is_empty():
		_on_miss(d.collider)
		if not infos.is_empty():erase(d.collider)

func _on_find(o:Object)->void:
	targets.append(o)

func _on_miss(o:Object)->void:
	targets.erase(o)

func clear()->void:
	target=null;targets.clear()
	infos.clear()

func apply(h:Physics.HitInfo)->void:
	if h==null||not h.rid.is_valid():return
	infos[h.rid]=h

func erase(o:Object)->void:
	if o==null and not o.has_method("get_rid"):return
	infos.erase(o.get_rid())

func fetch(o:Object)->Physics.HitInfo:
	if o==null and not o.has_method("get_rid"):return null
	return infos.get(o.get_rid(),null)

func detect()->bool:
	if dirty:_on_dirty()
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false
